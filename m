Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f47.google.com (mail-oa0-f47.google.com [209.85.219.47])
	by kanga.kvack.org (Postfix) with ESMTP id 332986B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 11:21:55 -0400 (EDT)
Received: by mail-oa0-f47.google.com with SMTP id n16so511789oag.34
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 08:21:54 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id uq9si789683obc.92.2014.06.24.08.21.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 08:21:54 -0700 (PDT)
Message-ID: <1403622753.25108.12.camel@misato.fc.hp.com>
Subject: Re: [PATCH 2/2] x86,mem-hotplug: modify PGD entry when removing
 memory
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 24 Jun 2014 09:12:33 -0600
In-Reply-To: <53A8C6F6.2060906@jp.fujitsu.com>
References: <53A132E2.9000605@jp.fujitsu.com>
		 <53A133ED.2090005@jp.fujitsu.com>
	 <1403289003.25108.3.camel@misato.fc.hp.com>
	 <53A8C6F6.2060906@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, tangchen@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, guz.fnst@cn.fujitsu.com, zhangyanfei@cn.fujitsu.com

On Tue, 2014-06-24 at 09:31 +0900, Yasuaki Ishimatsu wrote:
> (2014/06/21 3:30), Toshi Kani wrote:
> > On Wed, 2014-06-18 at 15:38 +0900, Yasuaki Ishimatsu wrote:
> >   :
> >> @@ -186,7 +186,12 @@ void sync_global_pgds(unsigned long start, unsigned long end)
> >>   		const pgd_t *pgd_ref = pgd_offset_k(address);
> >>   		struct page *page;
> >>
> >> -		if (pgd_none(*pgd_ref))
> >> +		/*
> >> +		 * When it is called after memory hot remove, pgd_none()
> >> +		 * returns true. In this case (removed == 1), we must clear
> >> +		 * the PGD entries in the local PGD level page.
> >> +		 */
> >> +		if (pgd_none(*pgd_ref) && !removed)
> >>   			continue;
> >>
> >>   		spin_lock(&pgd_lock);
> >> @@ -199,12 +204,18 @@ void sync_global_pgds(unsigned long start, unsigned long end)
> >>   			pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
> >>   			spin_lock(pgt_lock);
> >>
> >> -			if (pgd_none(*pgd))
> >> -				set_pgd(pgd, *pgd_ref);
> >> -			else
> 
> >> +			if (!pgd_none(*pgd_ref) && !pgd_none(*pgd))
> >>   				BUG_ON(pgd_page_vaddr(*pgd)
> >>   				       != pgd_page_vaddr(*pgd_ref));
> >>
> >> +			if (removed) {
> >
> > Shouldn't this condition be "else if"?
> 
> The first if sentence checks whether PGDs hit to BUG_ON. And the second
> if sentence checks whether the function was called after hot-removing memory.
> I think that the first if sentence and the second if sentence check different
> things. So I think the condition should be "if" sentence.

When the 1st if sentence is true, you have no additional operation and
the 2nd if sentence is redundant. But I agree that the two ifs can be
logically separated. So:

Acked-by: Toshi Kani <toshi.kani@hp.com>

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
