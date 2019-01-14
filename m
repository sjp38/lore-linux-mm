Return-Path: <SRS0=uJng=PW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9A15C43387
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 02:12:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5411120660
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 02:12:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5411120660
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B21FB8E0003; Sun, 13 Jan 2019 21:12:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A81788E0002; Sun, 13 Jan 2019 21:12:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94A8E8E0003; Sun, 13 Jan 2019 21:12:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 550238E0002
	for <linux-mm@kvack.org>; Sun, 13 Jan 2019 21:12:30 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t72so15174674pfi.21
        for <linux-mm@kvack.org>; Sun, 13 Jan 2019 18:12:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=uAeDxGu/6UmveiGP/mDbtM4KOyN6hOQN//Hl5ONGbAY=;
        b=oDff1rREYdSnZDnogkTccVOV8po//T6z9xuDeyL9vSK4Vx76X7YkbSVNBE6idcjxVo
         ivhsowVzF7LNB2Rzlf7SMQOlyb/aw7B/yY543xZXi24wXmOCBxpN79RRJkVAg5ZaLkIz
         mMJ/IuQODDiykpA5dVAN2lMpXpJJ/oaZaRJRxuM6dbpB3Yyq509PiMHRsgTJOyMvsI6/
         +b+hQlbBH1pDFvObvusRSGgvqJ5tvdo19Lv+upkB4HmTeL31k6KL+NQTYZjnKxDaRyxa
         nFYp5LI4RQWff1mpIOxYz7clWvU4QbtJs9mSTRWA3Xuec8I/PzrBdv8iSpoBGLIIxFsJ
         JXLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukeJvsiDYhBREJZ1Xiyz+gxNzPpGmw0R5a9C9YICWZtj5bHmBSUC
	8OPSEHTDchn88a3h8C9GHGLmCX98NfBsgfF40qKNGmGBmY/e1atPE7FZT9pwf9pEMaTRW2jhKqe
	sWYNcHnWNqE9CA0JWh0FE0+s2Abj4S+1Lqas1BXsubMFvWPl1hEI+/rKMAgjkOeoxDw==
X-Received: by 2002:a62:5c41:: with SMTP id q62mr23956472pfb.171.1547431950016;
        Sun, 13 Jan 2019 18:12:30 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7xorQjM68+XMf94VScfO9oFyIq/oLOdrLZeabxaqas2yKPU0dIA0JM/Rq5rA7ixa6Z3btv
X-Received: by 2002:a62:5c41:: with SMTP id q62mr23956418pfb.171.1547431949108;
        Sun, 13 Jan 2019 18:12:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547431949; cv=none;
        d=google.com; s=arc-20160816;
        b=uv7BYzFKutKx4C37MpB3/P2l7kpO/Pm7jmVaSTd9camyEs4dkIMAzcNp6R1ZXTx3Fu
         fVhkJMzHFoD3/lBhQxcWYz6DvgFuZeKgi9d/PflOGNWU+1LMZ7dabAl5mL+5EcmHksRt
         9IfR4QNlRcfbbL3OVNdJA9n12IrMYwCpH5jHBhCFA2nDZII9J4oPmBBOs8T+X88hVKFv
         s9BqohlEZtbAuP9n9IXQ1HKU9CzpxbmyOWmj6lRF1KZiFAEs+as0gACVWou/agPWm6tc
         lB9hpXTIds1kK9NWTw5uYx/EEL0Dvpako3LPyoyBKTaoD0pCbHZNBtAjrRHxuOaue2U+
         rE5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=uAeDxGu/6UmveiGP/mDbtM4KOyN6hOQN//Hl5ONGbAY=;
        b=vlk9j+lIrR+k4FfodRuLgkWH7WHhlqktDBB5h6ZirJ7pgm6dRVlA+RukykM5Lh7g/W
         P4V4862teZNXNI+O2IKvRmdyT2z1RtV8+oq2n87OirBsXkTaZ8z4TXCjDUecp98bxNFq
         fDyYeNjbc8wixuNzFBlzVXTgB84JxetLV0YMne/t4hqzOcIgEffocYX0AwSiYYww9I1X
         ALhtGoypRueJpgsJxGTnCL/EGrVmjrOx2mvd/QfPGqVESOMeGMmA4YHF9ZdI1rLV1MEK
         79IXpjwRdjjlBPPyLtomMxLs8UP4jwhBG9mK02PYpwU/FOG8ccKVmmQdByV8dGYbtbXl
         dSsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 44si21253607plc.110.2019.01.13.18.12.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Jan 2019 18:12:29 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Jan 2019 18:12:28 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,475,1539673200"; 
   d="scan'208";a="116504181"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.13.10])
  by fmsmga008.fm.intel.com with ESMTP; 13 Jan 2019 18:12:26 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>,  Andrew Morton <akpm@linux-foundation.org>,  Shaohua Li <shli@kernel.org>,  Dave Hansen <dave.hansen@linux.intel.com>,  Stephen Rothwell <sfr@canb.auug.org.au>,  Omar Sandoval <osandov@fb.com>,  Tejun Heo <tj@kernel.org>,  Andi Kleen <ak@linux.intel.com>,  <linux-mm@kvack.org>,  <kernel-janitors@vger.kernel.org>,  <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH] mm, swap: Potential NULL dereference in get_swap_page_of_type()
References: <20190111095919.GA1757@kadam>
	<20190111174128.oak64htbntvp7j6y@ca-dmjordan1.us.oracle.com>
Date: Mon, 14 Jan 2019 10:12:25 +0800
In-Reply-To: <20190111174128.oak64htbntvp7j6y@ca-dmjordan1.us.oracle.com>
	(Daniel Jordan's message of "Fri, 11 Jan 2019 09:41:28 -0800")
Message-ID: <87r2dgm1h2.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/25.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190114021225.D9-nsROMXRD56Hpav9VYtsel2acaYpp_Xkc3KJEFbR4@z>

Hi, Daniel,

Daniel Jordan <daniel.m.jordan@oracle.com> writes:

> On Fri, Jan 11, 2019 at 12:59:19PM +0300, Dan Carpenter wrote:
>> Smatch complains that the NULL checks on "si" aren't consistent.  This
>> seems like a real bug because we have not ensured that the type is
>> valid and so "si" can be NULL.
>> 
>> Fixes: ec8acf20afb8 ("swap: add per-partition lock for swapfile")
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>> ---
>>  mm/swapfile.c | 6 +++++-
>>  1 file changed, 5 insertions(+), 1 deletion(-)
>> 
>> diff --git a/mm/swapfile.c b/mm/swapfile.c
>> index f0edf7244256..21e92c757205 100644
>> --- a/mm/swapfile.c
>> +++ b/mm/swapfile.c
>> @@ -1048,9 +1048,12 @@ swp_entry_t get_swap_page_of_type(int type)
>>  	struct swap_info_struct *si;
>>  	pgoff_t offset;
>>  
>> +	if (type >= nr_swapfiles)
>> +		goto fail;
>> +
>
> As long as we're worrying about NULL, I think there should be an smp_rmb here
> to ensure swap_info[type] isn't NULL in case of an (admittedly unlikely) racing
> swapon that increments nr_swapfiles.  See smp_wmb in alloc_swap_info and the
> matching smp_rmb's in the file.  And READ_ONCE's on either side of the barrier
> per LKMM.

I think you are right here.  And smp_rmb() for nr_swapfiles are missing
in many other places in swapfile.c too (e.g. __swap_info_get(),
swapdev_block(), etc.).

In theory, I think we need to fix this.

Best Regards,
Huang, Ying

> I'm adding Andrea (randomly selected from the many LKMM folks to avoid spamming
> all) who can correct me if I'm wrong about any of this.
>
>>  	si = swap_info[type];
>>  	spin_lock(&si->lock);
>> -	if (si && (si->flags & SWP_WRITEOK)) {
>> +	if (si->flags & SWP_WRITEOK) {
>>  		atomic_long_dec(&nr_swap_pages);
>>  		/* This is called for allocating swap entry, not cache */
>>  		offset = scan_swap_map(si, 1);
>> @@ -1061,6 +1064,7 @@ swp_entry_t get_swap_page_of_type(int type)
>>  		atomic_long_inc(&nr_swap_pages);
>>  	}
>>  	spin_unlock(&si->lock);
>> +fail:
>>  	return (swp_entry_t) {0};
>>  }
>>  
>> -- 
>> 2.17.1
>> 

