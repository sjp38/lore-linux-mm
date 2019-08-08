Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D275C32751
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 03:27:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 197822186A
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 03:27:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 197822186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0BC36B0003; Wed,  7 Aug 2019 23:27:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 995206B0006; Wed,  7 Aug 2019 23:27:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E94E6B0007; Wed,  7 Aug 2019 23:27:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 459336B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 23:27:04 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id w5so56863165pgs.5
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 20:27:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ONx/jxyWsZmRyfYnFleBGFMIPyzgXzQefflrM1Nbgvc=;
        b=FzCABdckzF/cvByVRPu3i9Fn5Y5pr0HKgjPXts/r+/ps01Zw6Wbx/0HVAZkgujJHx8
         f3dPUCj5ceePTrpBMlhvCL661dM3cuJVhLv5phPmzA80gUMsoPKDF62EmiDANA0Fx8M8
         +Ri07+yp6rZ/sEsCoOCm22RYxfdJBiLO3URVqAa9g4g8c5r/Yt53cFEIvbnliiae15Yq
         pWjaIoEUzqkVQlHgT7B5wWioiOVtAhLrYSsUEX+6LYoI5JB/4UWJ12Dhp3SJ1BqfYUwy
         w6uzGjRvG5KLgDUxd5ku8iZx9kjNGPb1SA8p4QoIQdqYXguHmc3cNzenSfY11OvAjVWe
         e87Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXOWziRRmnukrFbo0m16vRUfkUurg8RXp4R+gANm9xMjSAoagz9
	RJ8bxSbYxc/aIPPyZV6HTQf5FHCq7dvYD/mf2ulSHZ30nF233eHMXR6TtNBhcHKiW57be1NwH5V
	tonGavVM8gkEFolmi/puzyXIjVwDYZ+OXf0dwc7hXVeGYkssimm6z3eyOUBjjXZ09cg==
X-Received: by 2002:aa7:8dd2:: with SMTP id j18mr12794262pfr.88.1565234823909;
        Wed, 07 Aug 2019 20:27:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+3BYURBjC1AMsLPVFjax0yNZXxaR16YtHKO4LnbwX2lmLnvJxIGcvY1HbiBXwistL18SR
X-Received: by 2002:aa7:8dd2:: with SMTP id j18mr12794211pfr.88.1565234822900;
        Wed, 07 Aug 2019 20:27:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565234822; cv=none;
        d=google.com; s=arc-20160816;
        b=kBtb/DaP8FKC1IMzAal98147zI5Ai+KQfSwn2S22KZvpwXvb8yTZH26xlHqTF3hjDt
         DfI0paqqF5GXbR1dyAgigRJmbHykAO4Z4DIbiF81/TBSLlhcq/gWG/Sx6CboChlp/rGR
         LOA6DtaPy86A/9oNwwjWWU3yToqOFYfsW5ygfNMHF5y5O9H2f3cbfPfxmUFjXU39BfM9
         0kglTf0IfpMePRSOjW9IONwl2mekTzusowoA0nxxXDG8+THAr7m6YH5JhJiFWiqWD6Ag
         tlJZs/FUQrR4TDlaTAEtM4dfMkz/u2Cas7Iellhosbpvl7ziD2QtWsNoxHoVuUNyitJS
         6Zlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date;
        bh=ONx/jxyWsZmRyfYnFleBGFMIPyzgXzQefflrM1Nbgvc=;
        b=IqprDDQW4oEjMpXCdSvOlmbQLclM6fqu8oCvG/wwteVa3pbuDpfVZO6YFswO8zaOtx
         msF8dCJJoaixVkm/+peV3tP90alaDw1lmf+RFxhDE+mfCfCsIR9/bBeLnEHvw5CMIdAF
         ym2oupZKvusaSLndb8DmbcUA/+Krwxj1XTM5yHfhQTg/RsdateWKyk8AQ/BwL3/cILAk
         BQV2m0iZkJX9ABrDUEWaw0K9+rYkbE46uGPA8M1x/7wuujxvIvadeZbgSfp0634koDqD
         G5DcyuUYMrwSptod0cQWdtMum7+Z8tRI3FycMarZJuVhRkpj905LC62ujc0dryC4do2m
         9j4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id a1si28308241pgh.570.2019.08.07.20.27.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 20:27:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Aug 2019 20:27:02 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,360,1559545200"; 
   d="scan'208";a="203426188"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by fmsmga002.fm.intel.com with ESMTP; 07 Aug 2019 20:27:01 -0700
Date: Thu, 8 Aug 2019 11:26:38 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richardw.yang@linux.intel.com>,
	Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org,
	kirill.shutemov@linux.intel.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/mmap.c: refine data locality of find_vma_prev
Message-ID: <20190808032638.GA28138@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <20190806081123.22334-1-richardw.yang@linux.intel.com>
 <3e57ba64-732b-d5be-1ad6-eecc731ef405@suse.cz>
 <20190807003109.GB24750@richard>
 <20190807075101.GN11812@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807075101.GN11812@dhcp22.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 09:51:01AM +0200, Michal Hocko wrote:
>On Wed 07-08-19 08:31:09, Wei Yang wrote:
>> On Tue, Aug 06, 2019 at 11:29:52AM +0200, Vlastimil Babka wrote:
>> >On 8/6/19 10:11 AM, Wei Yang wrote:
>> >> When addr is out of the range of the whole rb_tree, pprev will points to
>> >> the biggest node. find_vma_prev gets is by going through the right most
>> >
>> >s/biggest/last/ ? or right-most?
>> >
>> >> node of the tree.
>> >> 
>> >> Since only the last node is the one it is looking for, it is not
>> >> necessary to assign pprev to those middle stage nodes. By assigning
>> >> pprev to the last node directly, it tries to improve the function
>> >> locality a little.
>> >
>> >In the end, it will always write to the cacheline of pprev. The caller has most
>> >likely have it on stack, so it's already hot, and there's no other CPU stealing
>> >it. So I don't understand where the improved locality comes from. The compiler
>> >can also optimize the patched code so the assembly is identical to the previous
>> >code, or vice versa. Did you check for differences?
>> 
>> Vlastimil
>> 
>> Thanks for your comment.
>> 
>> I believe you get a point. I may not use the word locality. This patch tries
>> to reduce some unnecessary assignment of pprev.
>> 
>> Original code would assign the value on each node during iteration, this is
>> what I want to reduce.
>
>Is there any measurable difference (on micro benchmarks or regular
>workloads)?

I wrote a test case to compare these two methods, but not find visible
difference in run time.

While I found we may leverage rb_last to refine the code a little.

@@ -2270,12 +2270,9 @@ find_vma_prev(struct mm_struct *mm, unsigned long addr,
        if (vma) {
                *pprev = vma->vm_prev;
        } else {
-               struct rb_node *rb_node = mm->mm_rb.rb_node;
-               *pprev = NULL;
-               while (rb_node) {
-                       *pprev = rb_entry(rb_node, struct vm_area_struct, vm_rb);
-                       rb_node = rb_node->rb_right;
-               }
+               struct rb_node *rb_node = rb_last(&mm->mm_rb);
+               *pprev = !rb_node ? NULL :
+                        rb_entry(rb_node, struct vm_area_struct, vm_rb);
        }
        return vma;

Not sure this style would help a little in understanding the code?

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me

