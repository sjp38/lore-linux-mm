Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40A1DC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 16:52:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAEF720850
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 16:52:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAEF720850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 998886B000C; Fri, 12 Apr 2019 12:52:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9475D6B000D; Fri, 12 Apr 2019 12:52:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 838216B0010; Fri, 12 Apr 2019 12:52:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 339616B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 12:52:47 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r6so5144352edp.18
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 09:52:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=J8+nMcLsizTcpYafwM3rJgVhGUXw3HvEEw2X1EXjaUg=;
        b=i7AoBMljUAsZ5hIAVTgH3M8yiBlqvfdgq9e3NwpX4mGB0PVvTM3ezmBjAB5f703gsz
         WfifLybR+iXqX7jZxB2abJAJRXJdlBQrzd81vl4fPF4odAo6T9aU85B+yZuDqr3hXjO7
         4GwkqoSBNU3nXoBYkj6UoiQ+fynliFHOtg2wHiJcI7VuhneufK4rqFq5GTzxjqqEHl4U
         H+OJZnpf0e8jFjYYq+a0JSRY70oDEApN+bxad9gqngOzMl7n890GHg0bMHpgh6yUkEiy
         yqbF7lXCJGgDHjNGsUp2mPt2visGfvsIcEgfaGmSbiOqes5DMs6iFUkQLBml9fg1IN1G
         xLnQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAX3rEfQetsiHB9oJiv+jM8dnA71Jx/T2Ye3BJ/4JuXGrwNY1LMX
	aev2YIZFahyvNN3kxYQ//ccCpwOxJHdqvQUa19f3OQFQcdJvZMZQACeP2mnn2dUp6RPI/QYipfz
	lYuMOsu4ORZndJAlYOvVfN/kvu86ZjhAXaK8iA3kBvQSse/pLXBniymNVN/BV3KA=
X-Received: by 2002:a17:906:b291:: with SMTP id q17mr31839936ejz.56.1555087966686;
        Fri, 12 Apr 2019 09:52:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdVe4BS1TkwdabilJFG1JYJiIlvw1vrc09ndkp2fcVgTMmd5cLLSm0lGMHYx0uXAdm75To
X-Received: by 2002:a17:906:b291:: with SMTP id q17mr31839896ejz.56.1555087965736;
        Fri, 12 Apr 2019 09:52:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555087965; cv=none;
        d=google.com; s=arc-20160816;
        b=AVB0WPOlBvb/hUCp4L/edTq1Q/L2Hs534jBDMlHQS+5u9rvwB2f6Xpug6LpmoaOFwo
         BmTVbL4GnXWzRBbIVXeJfuQWt7QODMJFkmc+Jm4Bkh2pYXzyY5xmqiaNnoYz5Ubn3x39
         GagpAtORHj7GLVVcoO2NVCvC8WFDzl0uFJVReDUU/2iodiuOH2roX6PP6IaGMMoYmooE
         8ukhvcjbhNxKEilA0Q0ysSQGfH02M5p3Yz3+ImfaaJDTN+YAWjGrI+Qpug/D8y2ewKHE
         V9ueKYQF4pLdTcaLR9l9+r3pcCNRkMTnVy2409xImGCELFzm4eF28gAvi5mp0ewyQysS
         GhGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=J8+nMcLsizTcpYafwM3rJgVhGUXw3HvEEw2X1EXjaUg=;
        b=SOkuGaYfKqOPMiIx0CnH7oJ9Z1ZDbnL/W2vBnyoheyoJd5rZwb6spdalMOTA61dtN3
         GKy9wQ3gS7nWszLrnzas2AFbqCpsZ311IkMM4RjX8xBd1duekRTIN1n/rKRA1d61mLcg
         /EWBvSv47MPrkXELlddWyMX4mnFt0n0QyLde3GVM/2PWFL2dcFqpWhR2zzftZYNXPeHW
         iqICnhKk1/IVCmmozS5Q76zkqsl9lLmDMXmKNWk0M0UQnEk88uyyHC9oaxuvbowbk0+W
         sZeMp1DpvlhHNRP70/8AOLVcNaDvPEkSrnp8u4vL3FFhadj3R3h0yfojHVBPI7nmCbFk
         QahQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x26si879792edr.378.2019.04.12.09.52.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 09:52:45 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AEC46AE28;
	Fri, 12 Apr 2019 16:52:44 +0000 (UTC)
Date: Fri, 12 Apr 2019 09:52:35 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Michal Hocko <mhocko@kernel.org>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v2 2/2] hugetlb: use same fault hash key for shared and
 private mappings
Message-ID: <20190412165235.t4sscoujczfhuiyt@linux-r8p5>
Mail-Followup-To: Mike Kravetz <mike.kravetz@oracle.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Michal Hocko <mhocko@kernel.org>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
References: <20190328234704.27083-1-mike.kravetz@oracle.com>
 <20190328234704.27083-3-mike.kravetz@oracle.com>
 <0b1d1faf-ff72-a51f-b48a-175c9c5cab53@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <0b1d1faf-ff72-a51f-b48a-175c9c5cab53@oracle.com>
User-Agent: NeoMutt/20180323
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Apr 2019, Mike Kravetz wrote:

>On 3/28/19 4:47 PM, Mike Kravetz wrote:
>> hugetlb uses a fault mutex hash table to prevent page faults of the
>> same pages concurrently.  The key for shared and private mappings is
>> different.  Shared keys off address_space and file index.  Private
>> keys off mm and virtual address.  Consider a private mappings of a
>> populated hugetlbfs file.  A write fault will first map the page from
>> the file and then do a COW to map a writable page.
>
>Davidlohr suggested adding the stack trace to the commit log.  When I
>originally 'discovered' this issue I was debugging something else.  The
>routine remove_inode_hugepages() contains the following:
>
>			 * ...
>			 * This race can only happen in the hole punch case.
>			 * Getting here in a truncate operation is a bug.
>			 */
>			if (unlikely(page_mapped(page))) {
>				BUG_ON(truncate_op);
>
>				i_mmap_lock_write(mapping);
>				hugetlb_vmdelete_list(&mapping->i_mmap,
>					index * pages_per_huge_page(h),
>					(index + 1) * pages_per_huge_page(h));
>				i_mmap_unlock_write(mapping);
>			}
>
>			lock_page(page);
>			/*
>			 * We must free the huge page and remove from page
>			 * ...
>			 */
>			VM_BUG_ON(PagePrivate(page));
>			remove_huge_page(page);
>			freed++;
>
>I observed that the page could be mapped (again) before the call to lock_page
>if we raced with a private write fault.  However, for COW faults the faulting
>code is holding the page lock until it unmaps the file page.  Hence, we will
>not call remove_huge_page() with the page mapped.  That is good.  However, for
>simple read faults the page remains mapped after releasing the page lock and
>we can call remove_huge_page with a mapped page and BUG.
>
>Sorry, the original commit message was not completely accurate in describing
>the issue.  I was basing the change on behavior experienced during debug of
>a another issue.  Actually, it is MUCH easier to BUG by making private read
>faults race with hole punch.  As a result, I now think this should go to
>stable.
>
>Andrew, below is an updated commit message.  No changes to code.  Would you
>like me to send an updated patch?  Also, need to add stable.
>
>hugetlb uses a fault mutex hash table to prevent page faults of the
>same pages concurrently.  The key for shared and private mappings is
>different.  Shared keys off address_space and file index.  Private
>keys off mm and virtual address.  Consider a private mappings of a
>populated hugetlbfs file.  A fault will map the page from the file
>and if needed do a COW to map a writable page.
>
>Hugetlbfs hole punch uses the fault mutex to prevent mappings of file
>pages.  It uses the address_space file index key.  However, private
>mappings will use a different key and could race with this code to map
>the file page.  This causes problems (BUG) for the page cache remove
>code as it expects the page to be unmapped.  A sample stack is:
>
>page dumped because: VM_BUG_ON_PAGE(page_mapped(page))
>kernel BUG at mm/filemap.c:169!
>...
>RIP: 0010:unaccount_page_cache_page+0x1b8/0x200
>...
>Call Trace:
>__delete_from_page_cache+0x39/0x220
>delete_from_page_cache+0x45/0x70
>remove_inode_hugepages+0x13c/0x380
>? __add_to_page_cache_locked+0x162/0x380
>hugetlbfs_fallocate+0x403/0x540
>? _cond_resched+0x15/0x30
>? __inode_security_revalidate+0x5d/0x70
>? selinux_file_permission+0x100/0x130
>vfs_fallocate+0x13f/0x270
>ksys_fallocate+0x3c/0x80
>__x64_sys_fallocate+0x1a/0x20
>do_syscall_64+0x5b/0x180
>entry_SYSCALL_64_after_hwframe+0x44/0xa9
>
>There seems to be another potential COW issue/race with this approach
>of different private and shared keys as noted in commit 8382d914ebf7
>("mm, hugetlb: improve page-fault scalability").
>
>Since every hugetlb mapping (even anon and private) is actually a file
>mapping, just use the address_space index key for all mappings.  This
>results in potentially more hash collisions.  However, this should not
>be the common case.

This is fair enough as most mappings will be shared anyway (it would be
lovely to have some machinery to measure collisions in kernel hash tables,
in general).

>Fixes: b5cec28d36f5 ("hugetlbfs: truncate_hugepages() takes a range of pages")

Ok the issue was introduced after we had the mutex table.

>Cc: <stable@vger.kernel.org>

Thanks for the details, I'm definitely seeing the idx mismatch issue now.

Reviewed-by: Davidlohr Bueso <dbueso@suse.de>

