Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A66A5C43387
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 12:47:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50D2121871
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 12:47:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50D2121871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C79BD8E006F; Thu,  3 Jan 2019 07:47:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C29E98E0002; Thu,  3 Jan 2019 07:47:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF2458E006F; Thu,  3 Jan 2019 07:47:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 843728E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 07:47:36 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id n39so41224081qtn.18
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 04:47:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=yE2t+M4jaYRK0uoeoikKYlUukRUkLuSZAkfxUkN2uBU=;
        b=hAxuo/RNf+fCMc4tMGQxcCW6C94s1b8fV8XsmGcL32WWRoRCTvuBH20C62vUy1Wv8q
         CZMedQlFaRv09LSo39XQkydSZE2766qEf/aiMXulx3hQIGMCf0XS/igQjTHi0AReLVIT
         Y3o6R6lH76aYO2kzA0l5hiY/41CsgKqLI64DN8g8zh6p3fSomjuIMTXbpBHhIif+/QR1
         MOrD8CK8X1CoJVAGaODsm6cSRdeId6j8PuUco2aC5tc2S0/cwkNlJLrMhX4cgUFXGwxl
         E5C/IyQQDqT6LCP2mG6Xf6iQfe7ySfNLlcSY9tK7S7j1EnlKV3TssN/LZnCxp/IjAiTN
         tVWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AA+aEWZdshqy3VPZU1dkmkOweHzFbv8VmsXFpD4Z+yQEtCY+k0iZ/f4C
	fD/5K7YAWCVFDPxsRik2fauxs83e8HIt1/QSg4SUbO1XvRGmHLPznqMoYEHHAaXnTo0Iz3K7n6w
	y9PAvz6oIPPjiD2K6rcN4VW98rHfem9L51cfwsya5406NYne2/O2cTwBHH58GYuE4tw==
X-Received: by 2002:ac8:278a:: with SMTP id w10mr46275503qtw.149.1546519656264;
        Thu, 03 Jan 2019 04:47:36 -0800 (PST)
X-Google-Smtp-Source: AFSGD/UHkgMBfsJl1F2S7WToFL6EQLnnauclSvPD6Zq/msdwdhfP3tMkBC7GWwWBYD8ROsvuElZx
X-Received: by 2002:ac8:278a:: with SMTP id w10mr46275461qtw.149.1546519655295;
        Thu, 03 Jan 2019 04:47:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546519655; cv=none;
        d=google.com; s=arc-20160816;
        b=Kv6tn0tdnaNyyH3IQHPiVA//jCV8UgPQcLqAumq3PEeW94OrOTdA3VnWcFzLdBD7FS
         txL0oZTFYfReJJM1kv4aY/pGkSkjbE5aZg8eISIr4yRpBsYP0B/mRPo3hO7RHD3Yz0d8
         5p8LdWuH4fCTVmrZz6Zts3aCKl4tcIxirih61nOG+wO7MEv31Ft+1Mz73yHBejjyn1qj
         cxxfRTIj7XyEuS6LsGuycA+YpRw0UjUozgOu1ZOvSx1UIQxqUJc881l61Z2wBvy/7tat
         O+4yacKxI278gT4RNDO9+j20psP9vmMguYmW5GAGKmTmnfoqnQDTYAujuqsn648Lvbg6
         bFCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=yE2t+M4jaYRK0uoeoikKYlUukRUkLuSZAkfxUkN2uBU=;
        b=Eej8X7m9QwWZRZix1X5WisXp53bvKiguu1Ojtt5bVF1JGHofYqcVUcIn/wI0qab6Dm
         vvdf2GkWtdG5cpCGdS+jCTBHhK8y63cZWEY7mR9QyENxmmSI1tKLfVrYjlBRVxJimz5l
         2lgultW3ce9rjiq/Kb4H0vVBsAK9WOgYc3rs5wTTJxMzE40DurxOsfVyokF80ZPcLSaQ
         NCWsmXAY8jtNctgNSgYURNOb92ahnqEOoGG7BQOlrA+xIHQeh7YoJwT5Kc8B0V0EuAcT
         hms2O3jwThu8xkoBtp3HVcICQQYleUnIv+XByXg7kpcvbTlW5bOCdmf7oABbLoYwhZ94
         8XHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z34si1100056qvg.50.2019.01.03.04.47.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 04:47:35 -0800 (PST)
Received-SPF: pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E396F806BC;
	Thu,  3 Jan 2019 12:47:33 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A8A9C10840E6;
	Thu,  3 Jan 2019 12:47:33 +0000 (UTC)
Received: from zmail17.collab.prod.int.phx2.redhat.com (zmail17.collab.prod.int.phx2.redhat.com [10.5.83.19])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id 3DB7A41284;
	Thu,  3 Jan 2019 12:47:33 +0000 (UTC)
Date: Thu, 3 Jan 2019 07:47:32 -0500 (EST)
From: Jan Stancek <jstancek@redhat.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, kirill shutemov <kirill.shutemov@linux.intel.com>, 
	Andrew Morton <akpm@linux-foundation.org>, ltp@lists.linux.it, 
	mhocko@kernel.org, Rachel Sibley <rasibley@redhat.com>, 
	hughd@google.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, 
	aneesh kumar <aneesh.kumar@linux.vnet.ibm.com>, dave@stgolabs.net, 
	prakash sangappa <prakash.sangappa@oracle.com>, 
	colin king <colin.king@canonical.com>
Message-ID: <1808265696.93134171.1546519652798.JavaMail.zimbra@redhat.com>
In-Reply-To: <dc056866-0e60-6ffa-54d5-5cafa1a4a53f@oracle.com>
References: <1323128903.93005102.1546461004635.JavaMail.zimbra@redhat.com> <6e608107-e071-90c0-bd73-4215325433c1@oracle.com> <dc056866-0e60-6ffa-54d5-5cafa1a4a53f@oracle.com>
Subject: Re: [bug] problems with migration of huge pages with
 v4.20-10214-ge1ef035d272e
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.43.17.9, 10.4.195.16]
Thread-Topic: problems with migration of huge pages with v4.20-10214-ge1ef035d272e
Thread-Index: x/KDbXSS9ZtifY8KCQZrHvya/x6Qdg==
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 03 Jan 2019 12:47:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103124732.VEDQtdOTMQQS8uGP7tD1bAgGu0fsI8-dlMKupsYjpwE@z>



----- Original Message -----
> On 1/2/19 1:24 PM, Mike Kravetz wrote:
> > On 1/2/19 12:30 PM, Jan Stancek wrote:
> >> Hi,
> >>
> >> LTP move_pages12 [1] started failing recently.
> >>
> >> The test maps/unmaps some anonymous private huge pages
> >> and migrates them between 2 nodes. This now reliably
> >> hits NULL ptr deref:
> >>
> >> [  194.819357] BUG: unable to handle kernel NULL pointer dereference at
> >> 0000000000000030
> >> [  194.864410] #PF error: [WRITE]
> >> [  194.881502] PGD 22c758067 P4D 22c758067 PUD 235177067 PMD 0
> >> [  194.913833] Oops: 0002 [#1] SMP NOPTI
> >> [  194.935062] CPU: 0 PID: 865 Comm: move_pages12 Not tainted 4.20.0+ #1
> >> [  194.972993] Hardware name: HP ProLiant SL335s G7/, BIOS A24 12/08/2012
> >> [  195.005359] RIP: 0010:down_write+0x1b/0x40
> >> [  195.028257] Code: 00 5c 01 00 48 83 c8 03 48 89 43 20 5b c3 90 0f 1f 44
> >> 00 00 53 48 89 fb e8 d2 d7 ff ff 48 89 d8 48 ba 01 00 00 00 ff ff
> >> ff ff <f0> 48 0f c1 10 85 d2 74 05 e8 07 26 ff ff 65 48 8b 04 25 00 5c 01
> >> [  195.121836] RSP: 0018:ffffb87e4224fd00 EFLAGS: 00010246
> >> [  195.147097] RAX: 0000000000000030 RBX: 0000000000000030 RCX:
> >> 0000000000000000
> >> [  195.185096] RDX: ffffffff00000001 RSI: ffffffffa69d30f0 RDI:
> >> 0000000000000030
> >> [  195.219251] RBP: 0000000000000030 R08: ffffe7d4889d8008 R09:
> >> 0000000000000003
> >> [  195.258291] R10: 000000000000000f R11: ffffe7d4889d8008 R12:
> >> ffffe7d4889d0008
> >> [  195.294547] R13: ffffe7d490b78000 R14: ffffe7d4889d0000 R15:
> >> ffff8be9b2ba4580
> >> [  195.332532] FS:  00007f1670112b80(0000) GS:ffff8be9b7a00000(0000)
> >> knlGS:0000000000000000
> >> [  195.373888] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >> [  195.405938] CR2: 0000000000000030 CR3: 000000023477e000 CR4:
> >> 00000000000006f0
> >> [  195.443579] Call Trace:
> >> [  195.456876]  migrate_pages+0x833/0xcb0
> >> [  195.478070]  ? __ia32_compat_sys_migrate_pages+0x20/0x20
> >> [  195.506027]  do_move_pages_to_node.isra.63.part.64+0x2a/0x50
> >> [  195.536963]  kernel_move_pages+0x667/0x8c0
> >> [  195.559616]  ? __handle_mm_fault+0xb95/0x1370
> >> [  195.588765]  __x64_sys_move_pages+0x24/0x30
> >> [  195.611439]  do_syscall_64+0x5b/0x160
> >> [  195.631901]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> >> [  195.657790] RIP: 0033:0x7f166f5ff959
> >> [  195.676365] Code: 00 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 48
> >> 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08
> >> 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 17 45 2c 00 f7 d8 64 89 01 48
> >> [  195.772938] RSP: 002b:00007ffd8d77bb48 EFLAGS: 00000246 ORIG_RAX:
> >> 0000000000000117
> >> [  195.810207] RAX: ffffffffffffffda RBX: 0000000000000400 RCX:
> >> 00007f166f5ff959
> >> [  195.847522] RDX: 0000000002303400 RSI: 0000000000000400 RDI:
> >> 0000000000000360
> >> [  195.882327] RBP: 0000000000000400 R08: 0000000002306420 R09:
> >> 0000000000000004
> >> [  195.920017] R10: 0000000002305410 R11: 0000000000000246 R12:
> >> 0000000002303400
> >> [  195.958053] R13: 0000000002305410 R14: 0000000002306420 R15:
> >> 0000000000000003
> >> [  195.997028] Modules linked in: sunrpc amd64_edac_mod ipmi_ssif
> >> edac_mce_amd kvm_amd ipmi_si igb ipmi_devintf k10temp kvm pcspkr
> >> ipmi_msgha
> >> ndler joydev irqbypass sp5100_tco dca hpwdt hpilo i2c_piix4 xfs libcrc32c
> >> radeon i2c_algo_bit drm_kms_helper ttm ata_generic pata_acpi drm se
> >> rio_raw pata_atiixp
> >> [  196.134162] CR2: 0000000000000030
> >> [  196.152788] ---[ end trace 4420ea5061342d3e ]---
> >>
> >> Suspected commit is:
> >>   b43a99900559 ("hugetlbfs: use i_mmap_rwsem for more pmd sharing
> >>   synchronization")
> >> which adds to unmap_and_move_huge_page():
> >> +               struct address_space *mapping = page_mapping(hpage);
> >> +
> >> +               /*
> >> +                * try_to_unmap could potentially call huge_pmd_unshare.
> >> +                * Because of this, take semaphore in write mode here and
> >> +                * set TTU_RMAP_LOCKED to let lower levels know we have
> >> +                * taken the lock.
> >> +                */
> >> +               i_mmap_lock_write(mapping);
> >>
> >> If I'm reading this right, 'mapping' will be NULL for anon mappings.
> > 
> > Not exactly.
> > 
> 
> Well, yes exactly.  Sorry, I was confusing this with something else.
> 
> That commit does cause BUGs for migration and page poisoning of anon huge
> pages.  The patch was trying to take care of i_mmap_rwsem locking outside
> try_to_unmap infrastructure.  This is because try_to_unmap will take the
> semaphore in read mode (for file mappings) and we really need it to be
> taken in write mode.
> 
> The patch below continues to take the semaphore outside try_to_unmap for
> the file mapping case.  For anon mappings, the locking is done as a special
> case in try_to_unmap_one.  This is something I was trying to avoid as it
> it harder to follow/understand.  Any suggestions on how to restructure this
> or make it more clear are welcome.
> 
> Adding Andrew on Cc as he already sent the commit causing the BUGs upstream.
> 
> From: Mike Kravetz <mike.kravetz@oracle.com>
> 
> hugetlbfs: fix migration and poisoning of anon huge pages
> 
> Expanded use of i_mmap_rwsem for pmd sharing synchronization incorrectly
> used page_mapping() of anon huge pages to get to address_space
> i_mmap_rwsem.  Since page_mapping() is NULL for pages of anon mappings,
> an "unable to handle kernel NULL pointer" BUG would occur with stack
> similar to:
> 
> RIP: 0010:down_write+0x1b/0x40
> Call Trace:
>  migrate_pages+0x81f/0xb90
>  __ia32_compat_sys_migrate_pages+0x190/0x190
>  do_move_pages_to_node.isra.53.part.54+0x2a/0x50
>  kernel_move_pages+0x566/0x7b0
>  __x64_sys_move_pages+0x24/0x30
>  do_syscall_64+0x5b/0x180
>  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> 
> To fix, only use page_mapping() for non-anon or file pages.  For anon
> pages wait until we find a vma in which the page is mapped and get the
> address_space from vm_file.
> 
> Fixes: b43a99900559 ("hugetlbfs: use i_mmap_rwsem for more pmd sharing
> synchronization")
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Mike,

1) with LTP move_pages12 (MAP_PRIVATE version of reproducer)
Patch below fixes the panic for me.
It didn't apply cleanly to latest master, but conflicts were easy to resolve.

2) with MAP_SHARED version of reproducer
It still hangs in user-space.
v4.19 kernel appears to work fine so I've started a bisect.

Regards,
Jan

> ---
>  mm/memory-failure.c | 15 +++++++++++----
>  mm/migrate.c        | 34 +++++++++++++++++++++++-----------
>  mm/rmap.c           | 15 ++++++++++++---
>  3 files changed, 46 insertions(+), 18 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 93558fb981fb..f229cbd0b347 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1032,14 +1032,21 @@ static bool hwpoison_user_mappings(struct page *p,
> unsigned long pfn,
>  		unmap_success = try_to_unmap(hpage, ttu);
>  	} else if (mapping) {
>  		/*
> -		 * For hugetlb pages, try_to_unmap could potentially call
> -		 * huge_pmd_unshare.  Because of this, take semaphore in
> -		 * write mode here and set TTU_RMAP_LOCKED to indicate we
> -		 * have taken the lock at this higer level.
> +		 * For file mappings, take semaphore in write mode here and
> +		 * set TTU_RMAP_LOCKED to let lower levels know we have taken
> +		 * the lock.  This is in case lower levels call
> +		 * huge_pmd_unshare.  Without this, try_to_unmap would only
> +		 * take the semaphore in read mode.
>  		 */
>  		i_mmap_lock_write(mapping);
>  		unmap_success = try_to_unmap(hpage, ttu|TTU_RMAP_LOCKED);
>  		i_mmap_unlock_write(mapping);
> +	} else {
> +		/*
> +		 * For huge page anon mappings, try_to_unmap_one will take the
> +		 * i_mmap_rwsem before calling huge_pmd_unshare if necessary.
> +		 */
> +		unmap_success = try_to_unmap(hpage, ttu);
>  	}
>  	if (!unmap_success)
>  		pr_err("Memory failure: %#lx: failed to unmap page (mapcount=%d)\n",
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 725edaef238a..45d7dd0c9479 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1309,17 +1309,29 @@ static int unmap_and_move_huge_page(new_page_t
> get_new_page,
>  	if (page_mapped(hpage)) {
>  		struct address_space *mapping = page_mapping(hpage);
> 
> -		/*
> -		 * try_to_unmap could potentially call huge_pmd_unshare.
> -		 * Because of this, take semaphore in write mode here and
> -		 * set TTU_RMAP_LOCKED to let lower levels know we have
> -		 * taken the lock.
> -		 */
> -		i_mmap_lock_write(mapping);
> -		try_to_unmap(hpage,
> -			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS|
> -			TTU_RMAP_LOCKED);
> -		i_mmap_unlock_write(mapping);
> +		if (mapping) {
> +			/*
> +			 * For file mappings, take semaphore in write mode here
> +			 * and set TTU_RMAP_LOCKED to let lower levels know we
> +			 * have taken the lock.  This is in case lower levels
> +			 * call huge_pmd_unshare.  Without this, try_to_unmap
> +			 * would only take the semaphore in read mode.
> +			 */
> +			i_mmap_lock_write(mapping);
> +			try_to_unmap(hpage,
> +				TTU_MIGRATION|TTU_IGNORE_MLOCK|
> +				TTU_IGNORE_ACCESS|TTU_RMAP_LOCKED);
> +			i_mmap_unlock_write(mapping);
> +		} else {
> +			/*
> +			 * For anon mappings, try_to_unmap_one will take the
> +			 * i_mmap_rwsem before calling huge_pmd_unshare if
> +			 * necessary.
> +			 */
> +			try_to_unmap(hpage,
> +				TTU_MIGRATION|TTU_IGNORE_MLOCK|
> +				TTU_IGNORE_ACCESS);
> +		}
>  		page_was_mapped = 1;
>  	}
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index c566bd552535..b267cc084f92 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1375,11 +1375,17 @@ static bool try_to_unmap_one(struct page *page,
> struct
> vm_area_struct *vma,
>  		/*
>  		 * If sharing is possible, start and end will be adjusted
>  		 * accordingly.
> -		 *
> -		 * If called for a huge page, caller must hold i_mmap_rwsem
> -		 * in write mode as it is possible to call huge_pmd_unshare.
>  		 */
>  		adjust_range_if_pmd_sharing_possible(vma, &start, &end);
> +
> +		/*
> +		 * If called for a huge page file mapping, caller will hold
> +		 * i_mmap_rwsem in write mode.  For anon mappings, we must
> +		 * take the semaphore here.  All this is necessary because
> +		 * it is possible huge_pmd_unshare will 'unshare' a pmd.
> +		 */
> +		if (PageAnon(page))
> +			i_mmap_lock_write(vma->vm_file->f_mapping);
>  	}
>  	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
> 
> @@ -1655,6 +1661,9 @@ static bool try_to_unmap_one(struct page *page, struct
> vm_area_struct *vma,
>  	}
> 
>  	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
> +	/* For anon huge pages, we must unlock. */
> +	if (PageHuge(page) && PageAnon(page))
> +		i_mmap_unlock_write(vma->vm_file->f_mapping);
> 
>  	return ret;
>  }
> --
> 2.17.2
> 
> 

