Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 681AD6B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 10:57:24 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n13so4652976wmc.3
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 07:57:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o33si7522468edc.146.2017.11.27.07.57.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 07:57:22 -0800 (PST)
Subject: Re: [PATCH 01/18] mm: introduce MAP_SHARED_VALIDATE, a mechanism to
 safely define new mmap flags
References: <20171101153648.30166-1-jack@suse.cz>
 <20171101153648.30166-2-jack@suse.cz>
 <638b3b80-5cb9-97c2-5055-fef3a1ec25b9@suse.cz>
 <CAPcyv4gGRHWc6AH5Enb7njtmqHgd=g+0-mYMdd5wWjJMW0+d7g@mail.gmail.com>
 <20171122195318.GA29485@bombadil.infradead.org>
 <09f54d38-7cb5-343d-a017-2d71a793d05c@gmx.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <35fa2cb6-9957-fd77-836c-760cecc64b2e@suse.cz>
Date: Mon, 27 Nov 2017 16:55:54 +0100
MIME-Version: 1.0
In-Reply-To: <09f54d38-7cb5-343d-a017-2d71a793d05c@gmx.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Helge Deller <deller@gmx.de>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, "Darrick J . Wong" <darrick.wong@oracle.com>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Kees Cook <keescook@chromium.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-parisc@vger.kernel.org

On 11/25/2017 07:45 PM, Helge Deller wrote:
> On 22.11.2017 20:53, Matthew Wilcox wrote:
>> On Wed, Nov 22, 2017 at 08:52:37AM -0800, Dan Williams wrote:
>>> On Wed, Nov 22, 2017 at 4:02 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>>> On 11/01/2017 04:36 PM, Jan Kara wrote:
>>>>> From: Dan Williams <dan.j.williams@intel.com>
>>>>>
>>>>> The mmap(2) syscall suffers from the ABI anti-pattern of not validating
>>>>> unknown flags. However, proposals like MAP_SYNC need a mechanism to
>>>>> define new behavior that is known to fail on older kernels without the
>>>>> support. Define a new MAP_SHARED_VALIDATE flag pattern that is
>>>>> guaranteed to fail on all legacy mmap implementations.
>>>>
>>>> So I'm trying to make sense of this together with Michal's attempt for
>>>> MAP_FIXED_SAFE [1] where he has to introduce a completely new flag
>>>> instead of flag modifier exactly for the reason of not validating
>>>> unknown flags. And my conclusion is that because MAP_SHARED_VALIDATE
>>>> implies MAP_SHARED and excludes MAP_PRIVATE, MAP_FIXED_SAFE as a
>>>> modifier cannot build on top of this. Wouldn't thus it be really better
>>>> long-term to introduce mmap3 at this point? ...
>>>
>>> We have room to define MAP_PRIVATE_VALIDATE in MAP_TYPE on every arch
>>> except parisc. Can we steal an extra bit for MAP_TYPE from somewhere
>>> else on parisc?
>>
>> It looks like 0x08 should work.
> 
> I posted an RFC to the parisc mailing list for that:
> https://patchwork.kernel.org/patch/9970553/

Thanks. BTW there doesn't seem to be much interest making MAP_FIXED_SAFE
a flag modifier after all, so MAP_PRIVATE_VALIDATE wouldn't get
immediate users.

> Basically this is (for parisc only):
> -#define MAP_TYPE	0x03		/* Mask for type of mapping */
> +#define MAP_TYPE	(MAP_SHARED|MAP_PRIVATE|MAP_RESRVD1|MAP_RESRVD2) /* Mask for type of mapping */
>  #define MAP_FIXED	0x04		/* Interpret addr exactly */
> +#define MAP_RESRVD1	0x08		/* reserved for 3rd bit of MAP_TYPE */
>  #define MAP_ANONYMOUS	0x10		/* don't use a file */
> +#define MAP_RESRVD2	0x20		/* reserved for 4th bit of MAP_TYPE */
> 
>> But I don't have an HPUX machine around
>> to check that HP didn't use that bit for something else.
> 
> We completely dropped support for HPUX binaries, so it's not relvant any longer. 
> 
>> It'd probably help to cc the linux-parisc mailing list when asking
>> questions about PARISC, eh?
> 
> Yes, please.
> 
> Helge
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
