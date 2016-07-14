Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8AA6B0261
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 09:47:03 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p41so53652123lfi.0
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 06:47:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 78si9688206wms.98.2016.07.14.06.47.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 06:47:02 -0700 (PDT)
Subject: Re: [PATCH 4/4] x86: use pte_none() to test for empty PTE
References: <20160708001909.FB2443E2@viggo.jf.intel.com>
 <20160708001915.813703D9@viggo.jf.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <71d7b63a-45dd-c72d-a277-03124b0053ae@suse.cz>
Date: Thu, 14 Jul 2016 15:47:00 +0200
MIME-Version: 1.0
In-Reply-To: <20160708001915.813703D9@viggo.jf.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com, dave.hansen@intel.com, dave.hansen@linux.intel.com

On 07/08/2016 02:19 AM, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> The page table manipulation code seems to have grown a couple of
> sites that are looking for empty PTEs.  Just in case one of these
> entries got a stray bit set, use pte_none() instead of checking
> for a zero pte_val().
>
> The use pte_same() makes me a bit nervous.  If we were doing a
> pte_same() check against two cleared entries and one of them had
> a stray bit set, it might fail the pte_same() check.  But, I
> don't think we ever _do_ pte_same() for cleared entries.  It is
> almost entirely used for checking for races in fault-in paths.
>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

So, this might be just because I know next to nothing about (para)virt, 
but...

in arch/x86/include/asm/paravirt.h, pte_val is implemented via some 
pvops, which suggests that obtaining a pte value is different than just 
reading it from memory. But I don't see pte_none() defined to be using 
this on paravirt, and it shares (before patch 2/4) the "return !pte.pte" 
implementation, AFAICS?

So that itself is suspicious to me. And now that this patches does 
things like this:

-              if (pte_val(*pte)) {
+              if (!pte_none(*pte)) {

So previously on paravirt these tests would read pte via the pvops, and 
now they won't. Is that OK?

Thanks,
Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
