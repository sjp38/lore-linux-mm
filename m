Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20F97C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 16:48:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD0AA2177E
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 16:48:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD0AA2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 540D08E0003; Mon, 18 Feb 2019 11:48:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C8008E0002; Mon, 18 Feb 2019 11:48:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 342468E0003; Mon, 18 Feb 2019 11:48:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E0FE18E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 11:48:26 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 202so12369656pgb.6
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 08:48:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=RV/oh2ORD79gkOKqosC+5UIagqT7MtA6lO9pdUoRZKY=;
        b=NRILa6izzHQWfVT0JSl74UJ1WWwpG6Tg5i7gFQAOi2fc2DmIbG98/fjHPOfgmvuLjs
         K6dY6z0ClSnwZ7Rvyb10G4GEkh+3t1xEUgPO15+BeSb4YdMFTnYIn+q7e8cERcDcjVxa
         i1JMfcF4pEsblZ/ILhnEuN69m0q5QCmoY63cx7eBkt+Z12DDXj9lFs5ELwmvUpDq1FL5
         CGjEwbPxEsypREXmF0K4l8pFWaG0KdkcpPJ3n4Jo5igNTdYktVAJTE8IaPPG8Nm6KStg
         gWPgTui+WoKDO6oLjcg7H7DbOdcFA76LZRxoEG3LcFiVR3yOywRc0CE2XwT7EUy7uc81
         gELA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuY9qsFi2XhWJ3tWbJ5RsdEFQSpEi4shIlUUU2diQD5w9XytKRfs
	XDZ6ulmQ+kMM4TIdv2oEy2st9GBwC1QZQusyZq1ufShV1DPa0SI5Bdt8ZrM+DfhqaWYlQEQs2Uo
	e0zy6j8R+ArMv/CICdTiRTjkVficktpBZhYnOm0/LVHPu2i0E5jf2T8JM+KyV8uldFQ==
X-Received: by 2002:aa7:85cc:: with SMTP id z12mr25239497pfn.196.1550508506572;
        Mon, 18 Feb 2019 08:48:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbRCwLmB4lcHe6BcTYW0MCWpz/BwnxSluv/MhNlitditBC2YROdWCc885HshhzKqkYxuj00
X-Received: by 2002:aa7:85cc:: with SMTP id z12mr25239425pfn.196.1550508505419;
        Mon, 18 Feb 2019 08:48:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550508505; cv=none;
        d=google.com; s=arc-20160816;
        b=TFYf1yvNBsDoW3D3fm0r8eJlSKXTVMoBT9QdUbgYh96hLRGh6KCsdcRQZ5Gw8lGOsD
         O2/kYcAQ9mIon2Dii1GAvM6BxnZRkdha5afv9jrlm+4Gr6lb+EXiA7i8+HwoOL0v0hfc
         uiS0+i0ZPwIhCAUnpMHi5KxtCOySDHuPfR+iqt6BNitApa1OKuTOrJgvrV99fDWG9f5Y
         QEPVyKNge7tHyO6TJgz46BphY81rwzP9I0eLzgcRnCs1Y2Km4Mkm2mmW9yHr+6L02ADD
         hMWM7gMMT9zqwUmxPN8rf3M4iO9z0sUzHasDGwRP4WPl7kyjc0YVuW42ZYmNYbHH+VFz
         X3/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=RV/oh2ORD79gkOKqosC+5UIagqT7MtA6lO9pdUoRZKY=;
        b=usODeBhHalm8XkzteycvmdNIJr8V30i8ehMLC3EgiGnGROZtpZxrheycq9t19qJN77
         P6+K6VCX6acDJde93wY2D/1TkOjqWu9y6JHOvpHG/zy7bAJCncu+5pJbO8nnS76MPjUH
         882r+N7XB2q6nhzjonUTy/agwHoEPqW61tNbVP7FSdhvQxjmCKwnyRXb18cX1CNElxG1
         AECLdvPUILEy733RPcrf3Zv/4lR61pPGazrC5bOpSUhBRk/gjLgTL9iCnq7x2YpPJiYN
         2kTHaJ9D7NGcU7da0GAG2vTDPHOOoGHVcvsUNKSMA8dbDQybRi17RxtMNmzdrAabB3Xm
         fsSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v1si12845841pfm.264.2019.02.18.08.48.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 08:48:25 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1IGiL7j030575
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 11:48:24 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qqx7g8f9a-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 11:48:24 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 18 Feb 2019 16:48:22 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 18 Feb 2019 16:48:18 -0000
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1IGmH2S54001832
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 18 Feb 2019 16:48:17 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7FDAA4204C;
	Mon, 18 Feb 2019 16:48:17 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5E4DA42041;
	Mon, 18 Feb 2019 16:48:16 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.207.239])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 18 Feb 2019 16:48:15 +0000 (GMT)
Date: Mon, 18 Feb 2019 18:48:14 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Rong Chen <rong.a.chen@intel.com>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        linux-kernel@vger.kernel.org,
        Linux Memory Management List <linux-mm@kvack.org>,
        Andrew Morton <akpm@linux-foundation.org>, LKP <lkp@01.org>,
        Oscar Salvador <osalvador@suse.de>
Subject: Re: [LKP] efad4e475c [ 40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
References: <20190218052823.GH29177@shao2-debian>
 <20190218070844.GC4525@dhcp22.suse.cz>
 <20190218085510.GC7251@dhcp22.suse.cz>
 <4c75d424-2c51-0d7d-5c28-78c15600e93c@intel.com>
 <20190218103013.GK4525@dhcp22.suse.cz>
 <20190218140515.GF25446@rapoport-lnx>
 <20190218152050.GS4525@dhcp22.suse.cz>
 <20190218152213.GT4525@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218152213.GT4525@dhcp22.suse.cz>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19021816-0012-0000-0000-000002F72523
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021816-0013-0000-0000-0000212EAF17
Message-Id: <20190218164813.GG25446@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-18_13:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902180125
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 04:22:13PM +0100, Michal Hocko wrote:
> On Mon 18-02-19 16:20:50, Michal Hocko wrote:
> > On Mon 18-02-19 16:05:15, Mike Rapoport wrote:
> > > On Mon, Feb 18, 2019 at 11:30:13AM +0100, Michal Hocko wrote:
> > > > On Mon 18-02-19 18:01:39, Rong Chen wrote:
> > > > > 
> > > > > On 2/18/19 4:55 PM, Michal Hocko wrote:
> > > > > > [Sorry for an excessive quoting in the previous email]
> > > > > > [Cc Pavel - the full report is http://lkml.kernel.org/r/20190218052823.GH29177@shao2-debian[]
> > > > > > 
> > > > > > On Mon 18-02-19 08:08:44, Michal Hocko wrote:
> > > > > > > On Mon 18-02-19 13:28:23, kernel test robot wrote:
> > > > > > [...]
> > > > > > > > [   40.305212] PGD 0 P4D 0
> > > > > > > > [   40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
> > > > > > > > [   40.313055] CPU: 1 PID: 239 Comm: udevd Not tainted 5.0.0-rc4-00149-gefad4e4 #1
> > > > > > > > [   40.321348] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> > > > > > > > [   40.330813] RIP: 0010:page_mapping+0x12/0x80
> > > > > > > > [   40.335709] Code: 5d c3 48 89 df e8 0e ad 02 00 85 c0 75 da 89 e8 5b 5d c3 0f 1f 44 00 00 53 48 89 fb 48 8b 43 08 48 8d 50 ff a8 01 48 0f 45 da <48> 8b 53 08 48 8d 42 ff 83 e2 01 48 0f 44 c3 48 83 38 ff 74 2f 48
> > > > > > > > [   40.356704] RSP: 0018:ffff88801fa87cd8 EFLAGS: 00010202
> > > > > > > > [   40.362714] RAX: ffffffffffffffff RBX: fffffffffffffffe RCX: 000000000000000a
> > > > > > > > [   40.370798] RDX: fffffffffffffffe RSI: ffffffff820b9a20 RDI: ffff88801e5c0000
> > > > > > > > [   40.378830] RBP: 6db6db6db6db6db7 R08: ffff88801e8bb000 R09: 0000000001b64d13
> > > > > > > > [   40.386902] R10: ffff88801fa87cf8 R11: 0000000000000001 R12: ffff88801e640000
> > > > > > > > [   40.395033] R13: ffffffff820b9a20 R14: ffff88801f145258 R15: 0000000000000001
> > > > > > > > [   40.403138] FS:  00007fb2079817c0(0000) GS:ffff88801dd00000(0000) knlGS:0000000000000000
> > > > > > > > [   40.412243] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > > > > > > [   40.418846] CR2: 0000000000000006 CR3: 000000001fa82000 CR4: 00000000000006a0
> > > > > > > > [   40.426951] Call Trace:
> > > > > > > > [   40.429843]  __dump_page+0x14/0x2c0
> > > > > > > > [   40.433947]  is_mem_section_removable+0x24c/0x2c0
> > > > > > > This looks like we are stumbling over an unitialized struct page again.
> > > > > > > Something this patch should prevent from. Could you try to apply [1]
> > > > > > > which will make __dump_page more robust so that we do not blow up there
> > > > > > > and give some more details in return.
> > > > > > > 
> > > > > > > Btw. is this reproducible all the time?
> > > > > > And forgot to ask whether this is reproducible with pending mmotm
> > > > > > patches in linux-next.
> > > > > 
> > > > > 
> > > > > Do you mean the below patch? I can reproduce the problem too.
> > > > 
> > > > Yes, thanks for the swift response. The patch has just added a debugging
> > > > output
> > > > [    0.013697] Early memory node ranges
> > > > [    0.013701]   node   0: [mem 0x0000000000001000-0x000000000009efff]
> > > > [    0.013706]   node   0: [mem 0x0000000000100000-0x000000001ffdffff]
> > > > [    0.013711] zeroying 0-1
> > > > 
> > > > This is the first pfn.
> > > > 
> > > > [    0.013715] zeroying 9f-100
> > > > 
> > > > this is [mem 0x9f000, 0xfffff] so it fills up the whole hole between the
> > > > above two ranges. This is definitely good.
> > > > 
> > > > [    0.013722] zeroying 1ffe0-1ffe0
> > > > 
> > > > this is a single page at 0x1ffe0000 right after the zone end.
> > > > 
> > > > [    0.013727] Zeroed struct page in unavailable ranges: 98 pages
> > > > 
> > > > Hmm, so this is getting really interesting. The whole zone range should
> > > > be covered. So this is either some off-by-one or I something that I am
> > > > missing right now. Could you apply the following on top please? We
> > > > definitely need to see what pfn this is.
> > > > 
> > > > 
> > > > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > > > index 124e794867c5..59bcfd934e37 100644
> > > > --- a/mm/memory_hotplug.c
> > > > +++ b/mm/memory_hotplug.c
> > > > @@ -1232,12 +1232,14 @@ static bool is_pageblock_removable_nolock(struct page *page)
> > > >  /* Checks if this range of memory is likely to be hot-removable. */
> > > >  bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
> > > >  {
> > > > -	struct page *page = pfn_to_page(start_pfn);
> > > > +	struct page *page = pfn_to_page(start_pfn), *first_page;
> > > >  	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
> > > >  	struct page *end_page = pfn_to_page(end_pfn);
> > > > 
> > > >  	/* Check the starting page of each pageblock within the range */
> > > > -	for (; page < end_page; page = next_active_pageblock(page)) {
> > > > +	for (first_page = page; page < end_page; page = next_active_pageblock(page)) {
> > > > +		if (PagePoisoned(page))
> > > > +			pr_info("Unexpected poisoned page %px pfn:%lx\n", page, start_pfn + page-first_page);
> > > >  		if (!is_pageblock_removable_nolock(page))
> > > >  			return false;
> > > >  		cond_resched();
> > > 
> > > I've added more prints and somehow end_page gets too big (in brackets is
> > > the pfn):
> > > 
> > > [   11.183835] ===> start: ffff88801e240000(0), end: ffff88801e400000(8000)
> > > [   11.188457] ===> start: ffff88801e400000(8000), end: ffff88801e640000(10000)
> > > [   11.193266] ===> start: ffff88801e640000(10000), end: ffff88801e060000(18000)
> > > 
> > >                                                  should be ffff88801e5c0000
> > > 
> > > [   11.197363] ===> start: ffff88801e060000(18000), end: ffff88801e21f900(1ffe0)
> > > [   11.207547] Unexpected poisoned page ffff88801e5c0000 pfn:10000
> > > 
> > > 
> > > With the patch below the problem seem to disappear, although I have no idea
> > > why...
> > > 
> > > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > > index 91e6fef..53d15ff 100644
> > > --- a/mm/memory_hotplug.c
> > > +++ b/mm/memory_hotplug.c
> > > @@ -1234,7 +1234,7 @@ bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
> > >  {
> > >  	struct page *page = pfn_to_page(start_pfn);
> > >  	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
> > > -	struct page *end_page = pfn_to_page(end_pfn);
> > > +	struct page *end_page = page + (end_pfn - start_pfn);
> > >  
> > >  	/* Check the starting page of each pageblock within the range */
> > >  	for (; page < end_page; page = next_active_pageblock(page)) {
> > 
> > This is really interesting, because it would mean that the end_pfn is
> > out of the section and so the page pointer arithmetic doesn't really
> > work. But I am wondering how that could happen as nr_pages is
> > PAGES_PER_SECTION. Another option is that pfn_to_page doesn't work
> > properly here. It is CONFIG_SPARSEMEM. Could you print section_nr of
> > both start_pfn and end_pfn please?

[   11.118745] ===> start: ffff88801e240000(0), end: ffff88801e400000(8000)
[   11.118745] ===> s_sec: 0, e_sec: 1
[   11.123876] ===> start: ffff88801e640000(10000), end: ffff88801e060000(18000)
[   11.123876] ===> s_sec: 2, e_sec: 3
[   11.126835] ===> start: ffff88801e400000(8000), end: ffff88801e640000(10000)
[   11.126835] ===> s_sec: 1, e_sec: 2
[   11.130546] ===> start: ffff88801e060000(18000), end: ffff88801e21f900(1ffe0)
[   11.130546] ===> s_sec: 3, e_sec: 3
[   11.149693] Unexpected poisoned page ffff88801e5c0000 pfn:10000

The sections for start and end are different.

> Thinking about it some more, is it possible that we are overflowing by 1
> here?

Looks like that, the end_pfn is actually the first pfn in the next section.

> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 124e794867c5..6618b9d3e53a 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1234,10 +1234,10 @@ bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
>  {
>  	struct page *page = pfn_to_page(start_pfn);
>  	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
> -	struct page *end_page = pfn_to_page(end_pfn);
> +	struct page *end_page = pfn_to_page(end_pfn - 1);
>  
>  	/* Check the starting page of each pageblock within the range */
> -	for (; page < end_page; page = next_active_pageblock(page)) {
> +	for (; page <= end_page; page = next_active_pageblock(page)) {
>  		if (!is_pageblock_removable_nolock(page))
>  			return false;
>  		cond_resched();

Works with your fix, but I think mine is more intuitive ;-)

> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.

