Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 68C776B0031
	for <linux-mm@kvack.org>; Sun,  8 Sep 2013 12:56:57 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 9 Sep 2013 02:49:26 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 515A62CE804C
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 02:56:42 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r88GeDoC57671918
	for <linux-mm@kvack.org>; Mon, 9 Sep 2013 02:40:13 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r88GueIG010845
	for <linux-mm@kvack.org>; Mon, 9 Sep 2013 02:56:41 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: RE: [PATCH 2/2] thp: support split page table lock
In-Reply-To: <20130906104803.0F39CE0090@blue.fi.intel.com>
References: <1378416466-30913-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1378416466-30913-3-git-send-email-n-horiguchi@ah.jp.nec.com> <20130906104803.0F39CE0090@blue.fi.intel.com>
Date: Sun, 08 Sep 2013 22:26:29 +0530
Message-ID: <87y577gsle.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> Naoya Horiguchi wrote:
>> Thp related code also uses per process mm->page_table_lock now.
>> So making it fine-grained can provide better performance.
>> 
>> This patch makes thp support split page table lock by using page->ptl
>> of the pages storing "pmd_trans_huge" pmds.
>> 
>> Some functions like pmd_trans_huge_lock() and page_check_address_pmd()
>> are expected by their caller to pass back the pointer of ptl, so this
>> patch adds to those functions new arguments for that. Rather than that,
>> this patch gives only straightforward replacement.
>> 
>> ChangeLog v3:
>>  - fixed argument of huge_pmd_lockptr() in copy_huge_pmd()
>>  - added missing declaration of ptl in do_huge_pmd_anonymous_page()
>> 
>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>
> Generally, looks good. Few notes:
>
> I believe you need to convert __pte_alloc() to new locking. Not sure about
> __pte_alloc_kernel().
> Have you check all rest mm->page_table_lock, that they shouldn't be
> converted to new locking?

May be we can have a CONFIG_DEBUG_VM version of pmd_populate that check 
check with assert_spin_locked ?


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
