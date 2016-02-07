Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f171.google.com (mail-yw0-f171.google.com [209.85.161.171])
	by kanga.kvack.org (Postfix) with ESMTP id A39BB8309B
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 01:10:16 -0500 (EST)
Received: by mail-yw0-f171.google.com with SMTP id u200so3563415ywf.0
        for <linux-mm@kvack.org>; Sat, 06 Feb 2016 22:10:16 -0800 (PST)
Received: from mail-yw0-x232.google.com (mail-yw0-x232.google.com. [2607:f8b0:4002:c05::232])
        by mx.google.com with ESMTPS id w133si8589858ywa.310.2016.02.06.22.10.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Feb 2016 22:10:15 -0800 (PST)
Received: by mail-yw0-x232.google.com with SMTP id u200so3563287ywf.0
        for <linux-mm@kvack.org>; Sat, 06 Feb 2016 22:10:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160201214213.2bdf9b4e.akpm@linux-foundation.org>
References: <20160128061914.32541.97351.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20160201214213.2bdf9b4e.akpm@linux-foundation.org>
Date: Sat, 6 Feb 2016 22:10:15 -0800
Message-ID: <CAPcyv4jsLBsPfojMabS-B_kEu+gXM6xVQG5Aeo-7SUyM3rgfCw@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: CONFIG_NR_ZONES_EXTENDED
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Mark <markk@clara.co.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>

On Mon, Feb 1, 2016 at 9:42 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed, 27 Jan 2016 22:19:14 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

>>  #define GFP_ZONE_TABLE ( \
>> -     (ZONE_NORMAL << 0 * ZONES_SHIFT)                                      \
>> -     | (OPT_ZONE_DMA << ___GFP_DMA * ZONES_SHIFT)                          \
>> -     | (OPT_ZONE_HIGHMEM << ___GFP_HIGHMEM * ZONES_SHIFT)                  \
>> -     | (OPT_ZONE_DMA32 << ___GFP_DMA32 * ZONES_SHIFT)                      \
>> -     | (ZONE_NORMAL << ___GFP_MOVABLE * ZONES_SHIFT)                       \
>> -     | (OPT_ZONE_DMA << (___GFP_MOVABLE | ___GFP_DMA) * ZONES_SHIFT)       \
>> -     | (ZONE_MOVABLE << (___GFP_MOVABLE | ___GFP_HIGHMEM) * ZONES_SHIFT)   \
>> -     | (OPT_ZONE_DMA32 << (___GFP_MOVABLE | ___GFP_DMA32) * ZONES_SHIFT)   \
>> +     (ZONE_NORMAL << 0 * GFP_ZONES_SHIFT)                                    \
>> +     | (OPT_ZONE_DMA << ___GFP_DMA * GFP_ZONES_SHIFT)                        \
>> +     | (OPT_ZONE_HIGHMEM << ___GFP_HIGHMEM * GFP_ZONES_SHIFT)                \
>> +     | (OPT_ZONE_DMA32 << ___GFP_DMA32 * GFP_ZONES_SHIFT)                    \
>> +     | (ZONE_NORMAL << ___GFP_MOVABLE * GFP_ZONES_SHIFT)                     \
>> +     | (OPT_ZONE_DMA << (___GFP_MOVABLE | ___GFP_DMA) * GFP_ZONES_SHIFT)     \
>> +     | (ZONE_MOVABLE << (___GFP_MOVABLE | ___GFP_HIGHMEM) * GFP_ZONES_SHIFT) \
>> +     | (OPT_ZONE_DMA32 << (___GFP_MOVABLE | ___GFP_DMA32) * GFP_ZONES_SHIFT) \
>>  )
>
> Geeze.  Congrats on decrypting this stuff.  I hope.  Do you think it's
> possible to comprehensibly document it all for the next poor soul who
> ventures into it?
>

It is documented, just not included in the diff context.  At least the
existing documentation was enough for me to decipher that my changes
were doing the right thing:

/*
 * GFP_ZONE_TABLE is a word size bitstring that is used for looking up the
 * zone to use given the lowest 4 bits of gfp_t. Entries are ZONE_SHIFT long
 * and there are 16 of them to cover all possible combinations of
 * __GFP_DMA, __GFP_DMA32, __GFP_MOVABLE and __GFP_HIGHMEM.
 *
 * The zone fallback order is MOVABLE=>HIGHMEM=>NORMAL=>DMA32=>DMA.
 * But GFP_MOVABLE is not only a zone specifier but also an allocation
 * policy. Therefore __GFP_MOVABLE plus another zone selector is valid.
 * Only 1 bit of the lowest 3 bits (DMA,DMA32,HIGHMEM) can be set to "1".
 *
 *       bit       result
 *       =================
 *       0x0    => NORMAL
 *       0x1    => DMA or NORMAL
 *       0x2    => HIGHMEM or NORMAL
 *       0x3    => BAD (DMA+HIGHMEM)
 *       0x4    => DMA32 or DMA or NORMAL
 *       0x5    => BAD (DMA+DMA32)
 *       0x6    => BAD (HIGHMEM+DMA32)
 *       0x7    => BAD (HIGHMEM+DMA32+DMA)
 *       0x8    => NORMAL (MOVABLE+0)
 *       0x9    => DMA or NORMAL (MOVABLE+DMA)
 *       0xa    => MOVABLE (Movable is valid only if HIGHMEM is set too)
 *       0xb    => BAD (MOVABLE+HIGHMEM+DMA)
 *       0xc    => DMA32 (MOVABLE+DMA32)
 *       0xd    => BAD (MOVABLE+DMA32+DMA)
 *       0xe    => BAD (MOVABLE+DMA32+HIGHMEM)
 *       0xf    => BAD (MOVABLE+DMA32+HIGHMEM+DMA)
 *
 * GFP_ZONES_SHIFT must be <= 2 on 32 bit platforms.
 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
