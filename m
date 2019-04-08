Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8630C282DE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 06:57:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67BAA20880
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 06:57:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67BAA20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2214E6B028D; Mon,  8 Apr 2019 02:57:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D09A6B028E; Mon,  8 Apr 2019 02:57:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0991A6B028F; Mon,  8 Apr 2019 02:57:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A842F6B028D
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 02:57:28 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k8so6287764edl.22
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 23:57:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=JX4NsSEWMKIZq8QXWZQA15wAIG4xjcde0E0JzTiwd0k=;
        b=QTJEiLbxFkyrwQ9tQM/EVzCZ98is5Cdw2t/G9tx9NMCyI/mxRs9btLgCTQ9aNRHr4Z
         LxXatsx6vDMTl4sLA2h0WyjUQmek7Cr64zqNJalbCCnwARCx1LfDvxtXiIP/wLT0+Idt
         qdmhmFW7aJXOC2/yashRp4FEFTW5KN+4orpLQ+3cXsKMI6oXHSt1jzylv87Z48/1dIT/
         tunyuuVdaCgqsFGcjSh39FDme+rvUBAtufIQ0N4e5TbvF6ReoRRhwvK3qff4f93/p1W0
         Vz9ZTVtSj4dHuV27282Y54jEX4kEzmzHqAxn2g8zZO1qIexTzLvYwU4e2UZoTH9m8hfo
         176w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW9Dx6gzooWxVx1hzO33oL751qZJIf1vFGerYE3YLGwqnRGkR14
	2L2jBkt2cJ8oXlbfk3IBmu+EKTBni3A52oQo83xCUBub2H774QCbUG7RCEFepSyvV65uJat490n
	rM0/Udv9ZPLkI/d307hW7jmqgP+xnC9q23Ed9lnVkqSeBC22IQJ5Xo01nbVlvb8urhA==
X-Received: by 2002:a17:906:6992:: with SMTP id i18mr15455222ejr.224.1554706648212;
        Sun, 07 Apr 2019 23:57:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdOsnHvI2v/0/655DXzcKUBnmqyAl4Cx5bHEj2Oi8M9JSw9WN3NfJO9a2NNGuneqDLiGJg
X-Received: by 2002:a17:906:6992:: with SMTP id i18mr15455170ejr.224.1554706647145;
        Sun, 07 Apr 2019 23:57:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554706647; cv=none;
        d=google.com; s=arc-20160816;
        b=pb7tk6XZZX6x+r+MA9NdYsWYPDb94gRq0GL5tof14ay7i3mSfPKD+nbmXf16RG27Qk
         4uSMXUNjqu34pGulxgQc9/XNjP5FHO75aOzuGoT7qlpIm8uDfURBF8F4B07wvk7CD2qT
         PEXLbsAaX6YCD9nRarN/1xnGAXoMnmK24UIujL18oxRDVDA0fS1K8leu5ckJsQ/N9Mvt
         HAcIzte+hXTT6Tt0J0dXnyixqKcKy0Sa68uq9owt5r2osTRJy7vv1XGbkWej7OUmuFWB
         ghovA1neDepQUyVaGqwI4GCCdhk3hlF9kIgTVeJfF0pm8Az/5+vNyKxaZlpOxgFqluQn
         nE6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=JX4NsSEWMKIZq8QXWZQA15wAIG4xjcde0E0JzTiwd0k=;
        b=XNhObPd1y7PKwDPKqI4jPv+5DugQzodFaRCJBq1xxsCxmrhPSBaG9zSjKcZuWMP4Va
         rUreH4wiFwi37CUBbn4cc+ehoaN0JhFlqT2wjzvp4oQjN7LGfBIVtHNp8VJ/YB+mnM21
         OTkhgjWpyBxjCAsGd6gWp2dZlHdxs8WvH8owmdctNIjVw9iz2it8fkX8JYl3PCYT8gy2
         mzoq02kJf8uXsNI1NbfTOncGvklrzrngRB721j6aIjs5RzF1Ol5+TtdKtCl95F9EDHWj
         qfdCwjBOg6V+AfBG29IxwmC28vbGANDXLBRuoZ+CrByW2rn52yNNCoq6zzybcoFSM6lo
         r22g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z7si3679497ejn.268.2019.04.07.23.57.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 23:57:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x386oG7n012936
	for <linux-mm@kvack.org>; Mon, 8 Apr 2019 02:57:25 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rr049uy8s-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 08 Apr 2019 02:57:25 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 8 Apr 2019 07:57:23 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 8 Apr 2019 07:57:17 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x386vGwj61669536
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 8 Apr 2019 06:57:16 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B39554C052;
	Mon,  8 Apr 2019 06:57:16 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7B0BD4C04E;
	Mon,  8 Apr 2019 06:57:14 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.206.109])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon,  8 Apr 2019 06:57:14 +0000 (GMT)
Date: Mon, 8 Apr 2019 09:57:12 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Chen Zhou <chenzhou10@huawei.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org,
        ard.biesheuvel@linaro.org, takahiro.akashi@linaro.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        kexec@lists.infradead.org, linux-mm@kvack.org,
        wangkefeng.wang@huawei.com
Subject: Re: [PATCH 2/3] arm64: kdump: support more than one crash kernel
 regions
References: <20190403030546.23718-1-chenzhou10@huawei.com>
 <20190403030546.23718-3-chenzhou10@huawei.com>
 <20190403112929.GA7715@rapoport-lnx>
 <f98a5559-3659-fb35-3765-15861e70a796@huawei.com>
 <20190404144408.GA6433@rapoport-lnx>
 <783b8712-ddb1-a52b-81ee-0c6a216e5b7d@huawei.com>
 <4b188535-c12d-e05b-9154-2c2d580f903b@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4b188535-c12d-e05b-9154-2c2d580f903b@huawei.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19040806-0028-0000-0000-0000035E5F11
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19040806-0029-0000-0000-0000241D77B5
Message-Id: <20190408065711.GA8403@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-08_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904080064
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Apr 05, 2019 at 11:47:27AM +0800, Chen Zhou wrote:
> Hi Mike,
> 
> On 2019/4/5 10:17, Chen Zhou wrote:
> > Hi Mike,
> > 
> > On 2019/4/4 22:44, Mike Rapoport wrote:
> >> Hi,
> >>
> >> On Wed, Apr 03, 2019 at 09:51:27PM +0800, Chen Zhou wrote:
> >>> Hi Mike,
> >>>
> >>> On 2019/4/3 19:29, Mike Rapoport wrote:
> >>>> On Wed, Apr 03, 2019 at 11:05:45AM +0800, Chen Zhou wrote:
> >>>>> After commit (arm64: kdump: support reserving crashkernel above 4G),
> >>>>> there may be two crash kernel regions, one is below 4G, the other is
> >>>>> above 4G.
> >>>>>
> >>>>> Crash dump kernel reads more than one crash kernel regions via a dtb
> >>>>> property under node /chosen,
> >>>>> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>
> >>>>>
> >>>>> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
> >>>>> ---
> >>>>>  arch/arm64/mm/init.c     | 37 +++++++++++++++++++++++++------------
> >>>>>  include/linux/memblock.h |  1 +
> >>>>>  mm/memblock.c            | 40 ++++++++++++++++++++++++++++++++++++++++
> >>>>>  3 files changed, 66 insertions(+), 12 deletions(-)
> >>>>>
> >>>>> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> >>>>> index ceb2a25..769c77a 100644
> >>>>> --- a/arch/arm64/mm/init.c
> >>>>> +++ b/arch/arm64/mm/init.c
> >>>>> @@ -64,6 +64,8 @@ EXPORT_SYMBOL(memstart_addr);
> >>>>>  phys_addr_t arm64_dma_phys_limit __ro_after_init;
> >>>>>  
> >>>>>  #ifdef CONFIG_KEXEC_CORE
> >>>>> +# define CRASH_MAX_USABLE_RANGES        2
> >>>>> +
> >>>>>  static int __init reserve_crashkernel_low(void)
> >>>>>  {
> >>>>>  	unsigned long long base, low_base = 0, low_size = 0;
> >>>>> @@ -346,8 +348,8 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
> >>>>>  		const char *uname, int depth, void *data)
> >>>>>  {
> >>>>>  	struct memblock_region *usablemem = data;
> >>>>> -	const __be32 *reg;
> >>>>> -	int len;
> >>>>> +	const __be32 *reg, *endp;
> >>>>> +	int len, nr = 0;
> >>>>>  
> >>>>>  	if (depth != 1 || strcmp(uname, "chosen") != 0)
> >>>>>  		return 0;
> >>>>> @@ -356,22 +358,33 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
> >>>>>  	if (!reg || (len < (dt_root_addr_cells + dt_root_size_cells)))
> >>>>>  		return 1;
> >>>>>  
> >>>>> -	usablemem->base = dt_mem_next_cell(dt_root_addr_cells, &reg);
> >>>>> -	usablemem->size = dt_mem_next_cell(dt_root_size_cells, &reg);
> >>>>> +	endp = reg + (len / sizeof(__be32));
> >>>>> +	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
> >>>>> +		usablemem[nr].base = dt_mem_next_cell(dt_root_addr_cells, &reg);
> >>>>> +		usablemem[nr].size = dt_mem_next_cell(dt_root_size_cells, &reg);
> >>>>> +
> >>>>> +		if (++nr >= CRASH_MAX_USABLE_RANGES)
> >>>>> +			break;
> >>>>> +	}
> >>>>>  
> >>>>>  	return 1;
> >>>>>  }
> >>>>>  
> >>>>>  static void __init fdt_enforce_memory_region(void)
> >>>>>  {
> >>>>> -	struct memblock_region reg = {
> >>>>> -		.size = 0,
> >>>>> -	};
> >>>>> -
> >>>>> -	of_scan_flat_dt(early_init_dt_scan_usablemem, &reg);
> >>>>> -
> >>>>> -	if (reg.size)
> >>>>> -		memblock_cap_memory_range(reg.base, reg.size);
> >>>>> +	int i, cnt = 0;
> >>>>> +	struct memblock_region regs[CRASH_MAX_USABLE_RANGES];
> >>>>> +
> >>>>> +	memset(regs, 0, sizeof(regs));
> >>>>> +	of_scan_flat_dt(early_init_dt_scan_usablemem, regs);
> >>>>> +
> >>>>> +	for (i = 0; i < CRASH_MAX_USABLE_RANGES; i++)
> >>>>> +		if (regs[i].size)
> >>>>> +			cnt++;
> >>>>> +		else
> >>>>> +			break;
> >>>>> +	if (cnt)
> >>>>> +		memblock_cap_memory_ranges(regs, cnt);
> >>>>
> >>>> Why not simply call memblock_cap_memory_range() for each region?
> >>>
> >>> Function memblock_cap_memory_range() removes all memory type ranges except specified range.
> >>> So if we call memblock_cap_memory_range() for each region simply, there will be no usable-memory
> >>> on kdump capture kernel.
> >>
> >> Thanks for the clarification.
> >> I still think that memblock_cap_memory_ranges() is overly complex. 
> >>
> >> How about doing something like this:
> >>
> >> Cap the memory range for [min(regs[*].start, max(regs[*].end)] and then
> >> removing the range in the middle?
> > 
> > Yes, that would be ok. But that would do one more memblock_cap_memory_range operation.
> > That is, if there are n regions, we need to do (n + 1) operations, which doesn't seem to
> > matter.
> > 
> > I agree with you, your idea is better.
> > 
> > Thanks,
> > Chen Zhou
> 
> Sorry, just ignore my previous reply, I got that wrong.
> 
> I think it carefully, we can cap the memory range for [min(regs[*].start, max(regs[*].end)]
> firstly. But how to remove the middle ranges, we still can't use memblock_cap_memory_range()
> directly and the extra remove operation may be complex.
> 
> For more than one regions, i think add a new memblock_cap_memory_ranges() may be better.
> Besides, memblock_cap_memory_ranges() is also applicable for one region.
> 
> How about replace memblock_cap_memory_range() with memblock_cap_memory_ranges()?

arm64 is the only user of both MEMBLOCK_NOMAP and memblock_cap_memory_range()
and I don't expect other architectures will use these interfaces.
It seems that capping the memory for arm64 crash kernel the way I've
suggested can be implemented in fdt_enforce_memory_region(). If we'd ever
need such functionality elsewhere or CRASH_MAX_USABLE_RANGES will need to
grow we'll rethink the solution.
 
> Thanks,
> Chen Zhou

-- 
Sincerely yours,
Mike.

