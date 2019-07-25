Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F638C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 05:46:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E02C922BF5
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 05:46:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="kcP3nyGb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E02C922BF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64D0E8E002F; Thu, 25 Jul 2019 01:46:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FDAE8E001C; Thu, 25 Jul 2019 01:46:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C4328E002F; Thu, 25 Jul 2019 01:46:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3448E001C
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 01:46:50 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id q26so53636032ioi.10
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 22:46:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=O4N6qo0H8+pxgThdRlquGYN/8UdP1TMUlHR6Uew3RGM=;
        b=FN1KOXsZuCazDPy44tUS6lEU6hanF+vlp32RjSA5a1EwXhvllrZwXB5QNjWIYPTgov
         BnQPzU/aS7gKOfAUSNYqyNQGqQvgYNLHITNYgWIXD/8l7CImPZPkpYom8a9l4ck2Vc/Y
         OZPTm9LsPesPxU19VIPK0SXfR5iZHHEYWbukRA7jTz3mt8x+5tpgHCBlvIeeQ2uWFaqu
         klBPhCXWpJHb7Ekk/C7I79/T/sY39OrqeYDgRWLQJHEGTy5HtC+qXE/N3/gE8UjHr5gd
         qCpigAFsO7ekBcqC5s9gne0t+UcaanPOzEd+BkkHKe+CcJ5NYGLIG7EUSoMl9GwxwaXi
         rw4Q==
X-Gm-Message-State: APjAAAU6R4qTzeH8bBGfRscXNcYZx8rpg9kPafN3D/MUSsZim36AraJO
	Ep0N11RmZQlqVywJfV5F+eczUwjomwYbO76+msiQhIE6JcEivQ/Ex+nbL1BB08hdCs+pBS4nU+B
	ws3rlw3vdstrBTBk6MAbnQIveftW6u+DRXw7I5XkBXELXCc6P6KmFfAZA2Bl5WOt90w==
X-Received: by 2002:a6b:ed02:: with SMTP id n2mr17346386iog.131.1564033609914;
        Wed, 24 Jul 2019 22:46:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx03sOxjzEq+VeF9uIGvLSt/e9yCqMd/qZdmslGqgsJ5UQZrjywp86/8IVgUELsHWQPo35r
X-Received: by 2002:a6b:ed02:: with SMTP id n2mr17346343iog.131.1564033609052;
        Wed, 24 Jul 2019 22:46:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564033609; cv=none;
        d=google.com; s=arc-20160816;
        b=KDKFmJNeCjlb4wcy3hgbKuxIjvOo1X8wITOdsrj/Cn5t/XgSEIT31jjzszyMaIMuwF
         8emlAGrRiwTaJ2xOGxr9uevCEx6970FLq7+d0ifgkT+e0WzylMWeS0kc8LN7BvhGTb2M
         7ZN6i6QO3u5J/CKjM4pGCz13oNIP5TZ0hiiXA5+3DEkQUKmCrdOm0nd8CgxiTUPPIDI9
         IRzHwX3DO4TKDL4h3H7ZRo4YyQ1XOL+X08UuPna7wbc57GleG6R8aO9+KJH3bUORINWO
         wyh4ii3Xn8j6amP/C3a5aIobhJr8r4ydWYTqrwW1CkBkEUC0r/t4TiPKHJAJeJhN5igb
         2vTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=O4N6qo0H8+pxgThdRlquGYN/8UdP1TMUlHR6Uew3RGM=;
        b=lHA1gz7SrpFDqJvakcRYyg8eEXlk6FpnfFa7r+0Oy4Ti7zzqvMAeGdCjMTXxIvAGLM
         lud7vgpJKrV8X4M1D4JrU1I5uqgOQID9JiL14TBq72Lh6TvB4Iuz6PFRMcKCsIa3gTL6
         ffCk/UrpVt71wKlYR+VnEGFtGHCaDSvKsGN8ZKBSV3XmbkBLYUBZxiZyaQUe6LDk5s16
         FpTr6SAPc4XTB0zW7MPehPBCGIdxIDFEy3QaOVPPUhKE8Xl6DUoQCIt8aGIJXv0gw4xS
         V+G6nwPAihTplrH/zTBzqNsi6gevXHAyQyudLr7kDfJpWo1YSboWZy8sTBCctOaHxPf7
         2Clg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=kcP3nyGb;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id k16si67035jac.122.2019.07.24.22.46.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 22:46:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=kcP3nyGb;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6P5ha6R195564;
	Thu, 25 Jul 2019 05:46:45 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=O4N6qo0H8+pxgThdRlquGYN/8UdP1TMUlHR6Uew3RGM=;
 b=kcP3nyGbdvfWXEAo2NKmUD36GUr+SUWp0ujQP6SQBvWfDacDVXdAEqMbbdk3f+2/LIpB
 FuFGiEmZNVP77a33FZ8RexCDazhGl6/coROWJaHWUqRdEHZo4OnuUX4Uyj5OnRDLWfjH
 bPB0cc8lDhDYJwzATLR+Wi9yMTf6YV+28gu6CUPyEZ/p0rpIazFji09KQtmO/mkpUrDs
 UAg1vhZxGQ45a5w6LKqrAls8DT2OqIWSJl8Mpsv04pdiFuIj++9iQcRV1uXeohUNTDIc
 Tlh8TzxOeks5E0tMZHd+x+FCrFcT6N9gnebeyUyjPU0xEXs0zZik/401xIwrw+5oOTsU Ww== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2tx61c1g8m-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Jul 2019 05:46:45 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6P5h7nE110767;
	Thu, 25 Jul 2019 05:46:44 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2tx60xm1wa-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Jul 2019 05:46:44 +0000
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6P5khWC020893;
	Thu, 25 Jul 2019 05:46:43 GMT
Received: from [10.159.158.5] (/10.159.158.5)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 24 Jul 2019 22:46:42 -0700
Subject: Re: [PATCH v2 1/1] mm/memory-failure: Poison read receives SIGKILL
 instead of SIGBUS if mmaped more than once
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
References: <1564007603-9655-1-git-send-email-jane.chu@oracle.com>
 <1564007603-9655-2-git-send-email-jane.chu@oracle.com>
 <20190724234318.GA21820@hori.linux.bs1.fc.nec.co.jp>
From: Jane Chu <jane.chu@oracle.com>
Organization: Oracle Corporation
Message-ID: <3fa73abd-225c-cc71-719d-7ee296867ad4@oracle.com>
Date: Wed, 24 Jul 2019 22:46:31 -0700
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190724234318.GA21820@hori.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp; format=flowed; delsp=yes
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9328 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907250068
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9328 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907250068
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/24/2019 4:43 PM, Naoya Horiguchi wrote:
> On Wed, Jul 24, 2019 at 04:33:23PM -0600, Jane Chu wrote:
>> Mmap /dev/dax more than once, then read the poison location using address
>> from one of the mappings. The other mappings due to not having the page
>> mapped in will cause SIGKILLs delivered to the process. SIGKILL succeeds
>> over SIGBUS, so user process looses the opportunity to handle the UE.
>>
>> Although one may add MAP_POPULATE to mmap(2) to work around the issue,
>> MAP_POPULATE makes mapping 128GB of pmem several magnitudes slower, so
>> isn't always an option.
>>
>> Details -
>>
>> ndctl inject-error --block=10 --count=1 namespace6.0
>>
>> ./read_poison -x dax6.0 -o 5120 -m 2
>> mmaped address 0x7f5bb6600000
>> mmaped address 0x7f3cf3600000
>> doing local read at address 0x7f3cf3601400
>> Killed
>>
>> Console messages in instrumented kernel -
>>
>> mce: Uncorrected hardware memory error in user-access at edbe201400
>> Memory failure: tk->addr = 7f5bb6601000
>> Memory failure: address edbe201: call dev_pagemap_mapping_shift
>> dev_pagemap_mapping_shift: page edbe201: no PUD
>> Memory failure: tk->size_shift == 0
>> Memory failure: Unable to find user space address edbe201 in read_poison
>> Memory failure: tk->addr = 7f3cf3601000
>> Memory failure: address edbe201: call dev_pagemap_mapping_shift
>> Memory failure: tk->size_shift = 21
>> Memory failure: 0xedbe201: forcibly killing read_poison:22434 because of failure to unmap corrupted page
>>    => to deliver SIGKILL
>> Memory failure: 0xedbe201: Killing read_poison:22434 due to hardware memory corruption
>>    => to deliver SIGBUS
>>
>> Signed-off-by: Jane Chu <jane.chu@oracle.com>
>> Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> ---
>>   mm/memory-failure.c | 62 ++++++++++++++++++++++-------------------------------
>>   1 file changed, 26 insertions(+), 36 deletions(-)
>>
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index d9cc660..bd4db33 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -199,7 +199,6 @@ struct to_kill {
>>   	struct task_struct *tsk;
>>   	unsigned long addr;
>>   	short size_shift;
>> -	char addr_valid;
>>   };
>>   
>>   /*
>> @@ -304,43 +303,43 @@ static unsigned long dev_pagemap_mapping_shift(struct page *page,
>>   /*
>>    * Schedule a process for later kill.
>>    * Uses GFP_ATOMIC allocations to avoid potential recursions in the VM.
>> - * TBD would GFP_NOIO be enough?
>>    */
>>   static void add_to_kill(struct task_struct *tsk, struct page *p,
>>   		       struct vm_area_struct *vma,
>> -		       struct list_head *to_kill,
>> -		       struct to_kill **tkc)
>> +		       struct list_head *to_kill)
>>   {
>>   	struct to_kill *tk;
>>   
>> -	if (*tkc) {
>> -		tk = *tkc;
>> -		*tkc = NULL;
>> -	} else {
>> -		tk = kmalloc(sizeof(struct to_kill), GFP_ATOMIC);
>> -		if (!tk) {
>> -			pr_err("Memory failure: Out of memory while machine check handling\n");
>> -			return;
>> -		}
>> +	tk = kmalloc(sizeof(struct to_kill), GFP_ATOMIC);
>> +	if (!tk) {
>> +		pr_err("Memory failure: Out of memory while machine check handling\n");
>> +		return;
> 
> As Dan pointed out, the cleanup part can be delivered as a separate patch.

My bad, will take care splitting up the patch.

> 
>>   	}
>> +
>>   	tk->addr = page_address_in_vma(p, vma);
>> -	tk->addr_valid = 1;
>>   	if (is_zone_device_page(p))
>>   		tk->size_shift = dev_pagemap_mapping_shift(p, vma);
>>   	else
>>   		tk->size_shift = compound_order(compound_head(p)) + PAGE_SHIFT;
>>   
>>   	/*
>> -	 * In theory we don't have to kill when the page was
>> -	 * munmaped. But it could be also a mremap. Since that's
>> -	 * likely very rare kill anyways just out of paranoia, but use
>> -	 * a SIGKILL because the error is not contained anymore.
>> +	 * Send SIGKILL if "tk->addr == -EFAULT". Also, as
>> +	 * "tk->size_shift" is always non-zero for !is_zone_device_page(),
>> +	 * so "tk->size_shift == 0" effectively checks no mapping on
>> +	 * ZONE_DEVICE. Indeed, when a devdax page is mmapped N times
>> +	 * to a process' address space, it's possible not all N VMAs
>> +	 * contain mappings for the page, but at least one VMA does.
>> +	 * Only deliver SIGBUS with payload derived from the VMA that
>> +	 * has a mapping for the page.
> 
> OK, so SIGBUSs are sent M times (where M is the number of mappings
> for the page). Then I'm convinced that we need "else if" block below.

Yes. I run read_poison that mmaps /dev/dax 4 times with MAPS_POPULATE flag
set, so the kernel attempted sending SIGBUS 4 times.
One time, while the poison was consumed at uaddr[1] (2nd mmap), but the
SIGBUS payload indicated the si_addr was uaddr[3] (4th mmap).

thanks!
-jane


> 
> Thanks,
> Naoya Horiguchi
> 
>>   	 */
>> -	if (tk->addr == -EFAULT || tk->size_shift == 0) {
>> +	if (tk->addr == -EFAULT) {
>>   		pr_info("Memory failure: Unable to find user space address %lx in %s\n",
>>   			page_to_pfn(p), tsk->comm);
>> -		tk->addr_valid = 0;
>> +	} else if (tk->size_shift == 0) {
>> +		kfree(tk);
>> +		return;
>>   	}
>> +
>>   	get_task_struct(tsk);
>>   	tk->tsk = tsk;
>>   	list_add_tail(&tk->nd, to_kill);
>> @@ -366,7 +365,7 @@ static void kill_procs(struct list_head *to_kill, int forcekill, bool fail,
>>   			 * make sure the process doesn't catch the
>>   			 * signal and then access the memory. Just kill it.
>>   			 */
>> -			if (fail || tk->addr_valid == 0) {
>> +			if (fail || tk->addr == -EFAULT) {
>>   				pr_err("Memory failure: %#lx: forcibly killing %s:%d because of failure to unmap corrupted page\n",
>>   				       pfn, tk->tsk->comm, tk->tsk->pid);
>>   				do_send_sig_info(SIGKILL, SEND_SIG_PRIV,
>> @@ -432,7 +431,7 @@ static struct task_struct *task_early_kill(struct task_struct *tsk,
>>    * Collect processes when the error hit an anonymous page.
>>    */
>>   static void collect_procs_anon(struct page *page, struct list_head *to_kill,
>> -			      struct to_kill **tkc, int force_early)
>> +				int force_early)
>>   {
>>   	struct vm_area_struct *vma;
>>   	struct task_struct *tsk;
>> @@ -457,7 +456,7 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
>>   			if (!page_mapped_in_vma(page, vma))
>>   				continue;
>>   			if (vma->vm_mm == t->mm)
>> -				add_to_kill(t, page, vma, to_kill, tkc);
>> +				add_to_kill(t, page, vma, to_kill);
>>   		}
>>   	}
>>   	read_unlock(&tasklist_lock);
>> @@ -468,7 +467,7 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
>>    * Collect processes when the error hit a file mapped page.
>>    */
>>   static void collect_procs_file(struct page *page, struct list_head *to_kill,
>> -			      struct to_kill **tkc, int force_early)
>> +				int force_early)
>>   {
>>   	struct vm_area_struct *vma;
>>   	struct task_struct *tsk;
>> @@ -492,7 +491,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
>>   			 * to be informed of all such data corruptions.
>>   			 */
>>   			if (vma->vm_mm == t->mm)
>> -				add_to_kill(t, page, vma, to_kill, tkc);
>> +				add_to_kill(t, page, vma, to_kill);
>>   		}
>>   	}
>>   	read_unlock(&tasklist_lock);
>> @@ -501,26 +500,17 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
>>   
>>   /*
>>    * Collect the processes who have the corrupted page mapped to kill.
>> - * This is done in two steps for locking reasons.
>> - * First preallocate one tokill structure outside the spin locks,
>> - * so that we can kill at least one process reasonably reliable.
>>    */
>>   static void collect_procs(struct page *page, struct list_head *tokill,
>>   				int force_early)
>>   {
>> -	struct to_kill *tk;
>> -
>>   	if (!page->mapping)
>>   		return;
>>   
>> -	tk = kmalloc(sizeof(struct to_kill), GFP_NOIO);
>> -	if (!tk)
>> -		return;
>>   	if (PageAnon(page))
>> -		collect_procs_anon(page, tokill, &tk, force_early);
>> +		collect_procs_anon(page, tokill, force_early);
>>   	else
>> -		collect_procs_file(page, tokill, &tk, force_early);
>> -	kfree(tk);
>> +		collect_procs_file(page, tokill, force_early);
>>   }
>>   
>>   static const char *action_name[] = {
>> -- 
>> 1.8.3.1
>>
>>

