Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74F23C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:04:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32E9A208CA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:04:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32E9A208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0D706B000A; Mon, 13 May 2019 10:04:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBD9F6B000C; Mon, 13 May 2019 10:04:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A86066B000D; Mon, 13 May 2019 10:04:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 595E76B000A
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:04:52 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e21so18120662edr.18
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:04:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=30SGRYJWatyxOMBGxKrmHE4Fvzki7lX3J75GRBJEJ48=;
        b=qPjz51b8htaGjaId2edSZjbbv1+MyLBWBRlShg+qlBOL1zTWkHhZf5DPQH479IRHFR
         5dvfiOAlRT1Dn+aRsl5lEFEt34GKlon2FxgvVI2Bm3T8UIitATvptVat2tDTMyW4y2k/
         2mlXY2Vo/fGPO7O/0Fn0xik6G03acWKYCiSWFOrW6VLyQSq5T8iuRKOizEoxexAuCPDs
         m0esSF9s0NBZoNBaKD3Ng88a20UdCFrQxdCBpNUdNdnD9FmTCgA6kf3KbuPvtaSzlIuP
         Mxhq0r3N7K39UPaorjNlkZwnaaIkdbx5n8ZCqI/x0rg5HJKOhslKHGOBd+vTLa8+8E93
         AnIQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVPkQMKbIoNJAFIUJDcQ8PAaWcK7SvE5QNmptrAAjmA0phkQyPp
	t59e4maDTWXZWySbFWTRhwxyMEziWEMIaQF5nRwWSBnF1R5NTy0/O31YKKxpOr8oNgAX70zcsNh
	0ng9bdYoXqtBWIGrbEuFYVu67hCwj2SLcEzGzsXzOTA24RdcSi/djkSgP+fIZwY4=
X-Received: by 2002:a17:906:4911:: with SMTP id b17mr16649097ejq.3.1557756291727;
        Mon, 13 May 2019 07:04:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznlkc/vsKYjYgL5QxcFncqPY1NAzRWL2oTpb/bNbK5o1FbbknmjsVdn4kKOMyjKy5xrIPP
X-Received: by 2002:a17:906:4911:: with SMTP id b17mr16648957ejq.3.1557756290542;
        Mon, 13 May 2019 07:04:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557756290; cv=none;
        d=google.com; s=arc-20160816;
        b=dwcmpG0DPMCS0FAV7JM7H7urjBaNNN6OVQNcsM5Z+Bd+YcfnVgGRI94kZtY6MQpWCz
         x7EefWJ2EL1wzPW+RhfArDri+jNMdtmg2AmQBgf3sS5UcjMCZwg9esg++SHc17OcV5dw
         B1+mDDEscq2HYcwIVrY6IzqO4lr+9f+e3YXf62gMbJAe9CEsxVbdEwGZAjnuJVqwdQLB
         wjakunO28jFmaxYs6IY3NGI0acYeX6rjxL286zLP5MjsG1VFxtbexyBy8Kb0f+Ja0/0G
         0Y3T3jxC4nr3FeKjcNHC2GoONx3heRz8I36RSinQDIWi2ynuMp7fCHJIXHlGgSTSy3Eu
         zOzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=30SGRYJWatyxOMBGxKrmHE4Fvzki7lX3J75GRBJEJ48=;
        b=uT0NzCCfWaK58AEmpwjARTJG5kB8/EHbMVxDfv2IayfiKlwYjp86mnqYHj1zCIWK0+
         FJWAI36tglwqVJ+QCrBUv70S9lsT731gi2AxGtymiHkJYTfzzh0HCDiuraB651rKD29Z
         K7erD+6OPij1Td4erzy4OXw0bTsZ+luebue4Tt7hWsWEcskKWYnsuWOfKDf7KmcBNmt5
         Q16iVvaXg73mdMg8YSF9L31dPVto/LT7h7U3IGO2C7Z54sR0Cv9y/1HDIUSfDgxY/FCm
         7BP4C0u0BijiB4fGFT1SZsOdyavplHIwV6C5aMCzCeo9mGW7pjAWJPl70Wl8Ql8sslbM
         U8xA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v3si961024edm.338.2019.05.13.07.04.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:04:50 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DAEDAAD0A;
	Mon, 13 May 2019 14:04:49 +0000 (UTC)
Date: Mon, 13 May 2019 16:04:48 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, brho@google.com, kernelfans@gmail.com,
	dave.hansen@intel.com, rppt@linux.ibm.com, peterz@infradead.org,
	mpe@ellerman.id.au, mingo@elte.hu, osalvador@suse.de,
	luto@kernel.org, tglx@linutronix.de, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH -next v2] mm/hotplug: fix a null-ptr-deref during NUMA
 boot
Message-ID: <20190513140448.GJ24036@dhcp22.suse.cz>
References: <20190512054829.11899-1-cai@lca.pw>
 <20190513124112.GH24036@dhcp22.suse.cz>
 <1557755039.6132.23.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557755039.6132.23.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 13-05-19 09:43:59, Qian Cai wrote:
> On Mon, 2019-05-13 at 14:41 +0200, Michal Hocko wrote:
> > On Sun 12-05-19 01:48:29, Qian Cai wrote:
> > > The linux-next commit ("x86, numa: always initialize all possible
> > > nodes") introduced a crash below during boot for systems with a
> > > memory-less node. This is due to CPUs that get onlined during SMP boot,
> > > but that onlining triggers a page fault in bus_add_device() during
> > > device registration:
> > > 
> > > 	error = sysfs_create_link(&bus->p->devices_kset->kobj,
> > > 
> > > bus->p is NULL. That "p" is the subsys_private struct, and it should
> > > have been set in,
> > > 
> > > 	postcore_initcall(register_node_type);
> > > 
> > > but that happens in do_basic_setup() after smp_init().
> > > 
> > > The old code had set this node online via alloc_node_data(), so when it
> > > came time to do_cpu_up() -> try_online_node(), the node was already up
> > > and nothing happened.
> > > 
> > > Now, it attempts to online the node, which registers the node with
> > > sysfs, but that can't happen before the 'node' subsystem is registered.
> > > 
> > > Since kernel_init() is running by a kernel thread that is in
> > > SYSTEM_SCHEDULING state, fixed this by skipping registering with sysfs
> > > during the early boot in __try_online_node().
> > 
> > Relying on SYSTEM_SCHEDULING looks really hackish. Why cannot we simply
> > drop try_online_node from do_cpu_up? Your v2 remark below suggests that
> > we need to call node_set_online because something later on depends on
> > that. Btw. why do we even allocate a pgdat from this path? This looks
> > really messy.
> 
> See the commit cf23422b9d76 ("cpu/mem hotplug: enable CPUs online before local
> memory online")
> 
> It looks like try_online_node() in do_cpu_up() is needed for memory hotplug
> which is to put its node online if offlined and then hotadd_new_pgdat() calls
> build_all_zonelists() to initialize the zone list.

Well, do we still have to followthe logic that the above (unreviewed)
commit has established? The hotplug code in general made a lot of ad-hoc
design decisions which had to be revisited over time. If we are not
allocating pgdats for newly added memory then we should really make sure
to do so at a proper time and hook. I am not sure about CPU vs. memory
init ordering but even then I would really prefer if we could make the
init less obscure and _documented_.
 
-- 
Michal Hocko
SUSE Labs

