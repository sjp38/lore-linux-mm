Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 454E8C04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:31:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03EA021473
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:31:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03EA021473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A9116B027C; Mon, 13 May 2019 11:31:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 933446B027D; Mon, 13 May 2019 11:31:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FABD6B027E; Mon, 13 May 2019 11:31:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA006B027C
	for <linux-mm@kvack.org>; Mon, 13 May 2019 11:31:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f41so18565210ede.1
        for <linux-mm@kvack.org>; Mon, 13 May 2019 08:31:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/IOC6rsDmw+OsVb4dMAbXy9WLS0AQv7iZ7sBbfMbyrs=;
        b=co/LJDZ+scVywJwAMue3xSCtJw6s7PtDliDJq3aOINZsQd+gHy9/Uxf7ZAStppUrgk
         mzoh5m/p5JMah6LGBML6rmTGEn+iyH6PNxvDt8T4uHF+NUvJd9gr/NbseWsok9obtBhR
         D6SsBRRruhaRFQ2/vCVh3WtjyOBbiuytbl+x5TzQdbeYOYNNufVg8T+BWFGWrBMpjxgX
         1Ey5t+YL1Svj3gF7YfgAvQVEcIu0sY2D/odtzooT7IDIpzJTqvSpYM896Z0mUcBcc3AK
         4RjZdhB0yh7FtY94G+vQ2zO6mI/c5luVJk6NDZ/v/cTds/qFAYNpazj5t0Tofg0b5/Tk
         yx8A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV42CNdFC2takbsaESt1J7QrlHHPX6lOlWgL2H5NBAsVPsWYJGl
	1Gkfkd9oQmWhtTSRVfuTuR7z2nK2wX14ySLeSKKASu+6EpS5FdnD+ESBnrfAXN1UXQk5TV5F+fK
	3O5PA1qq+C0kq1wQNOb+q5AQ/6N12xpLzp1h8MZC/xJxY1F7R5SMNwNBkJZXQDC4=
X-Received: by 2002:a50:f4fb:: with SMTP id v56mr31067554edm.13.1557761508451;
        Mon, 13 May 2019 08:31:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSyguddWfruCzcyUutiBmF1WrWqkwHyoR9Vd3Uz/Dswza4q0L00Wj0lF4YPwC7td7ceiSw
X-Received: by 2002:a50:f4fb:: with SMTP id v56mr31067399edm.13.1557761507285;
        Mon, 13 May 2019 08:31:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557761507; cv=none;
        d=google.com; s=arc-20160816;
        b=v/xTx2b9fWuHLuPBOJKSY+lSTQzMYS9PyJSw+LVEtDPAYINVdgSlz+MZyPTkGpgMxd
         MFRHwEywK0sTLGDk8xXG3nBvriemQfTXhL2ALnNAlIdSN17/caYNxjBGfx1tGpTJrPlI
         6F8ux7HfnKe1xJKJnp59pOePNXJTyJoCR+FdUk0JTEeU+iDSOEQs34E2Pv6O9+KrQrUW
         re22j91OYyY0UcBDkg+9Wm98MOWlefpf4SNaH0Ytr5lkDym5xT3IrDdqeUZ0zv1uH1t6
         v7Nw7eCyEGela1knDiubhrUzZPFf1USzw8ZoC66sZaw+xYfRIC5JeemhgV6pokJHWl92
         3wjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/IOC6rsDmw+OsVb4dMAbXy9WLS0AQv7iZ7sBbfMbyrs=;
        b=TDQsebkKN2dhQii8EEjpeUjNzcQJSF21obk6A069hLpu2EeBvoeAIj/nlisP98Kzjd
         9yqeMlmQY6E/wtFQb8vnishzsSLqFgRNWCqEensDvzYII1UcZ9IKx3dyPxB6u0x7OR16
         HzBrtQ/S7SwkCrhuLpvGof864Fr+1WlswWMa1OVkxiD6cO7noAOUl/NLVdRomluB/PEi
         ycj4fYY8GdJWzPij5miYFHsUTrVQwG1n9hJ07HcWE1FWUjMy85/q14s7RegZaNIEztr3
         wum32/XpAi4PF7+Dp9A15SPcO7eOWemphjsdrqMkk6o5i7zOpDKPJHIdAm+pDhaiqamd
         ge9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 49si1985427eds.312.2019.05.13.08.31.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 08:31:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3DE8BAFCE;
	Mon, 13 May 2019 15:31:46 +0000 (UTC)
Date: Mon, 13 May 2019 17:31:43 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, brho@google.com, kernelfans@gmail.com,
	dave.hansen@intel.com, rppt@linux.ibm.com, peterz@infradead.org,
	mpe@ellerman.id.au, mingo@elte.hu, osalvador@suse.de,
	luto@kernel.org, tglx@linutronix.de, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH -next v2] mm/hotplug: fix a null-ptr-deref during NUMA
 boot
Message-ID: <20190513153143.GK24036@dhcp22.suse.cz>
References: <20190512054829.11899-1-cai@lca.pw>
 <20190513124112.GH24036@dhcp22.suse.cz>
 <1557755039.6132.23.camel@lca.pw>
 <20190513140448.GJ24036@dhcp22.suse.cz>
 <1557760846.6132.25.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557760846.6132.25.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 13-05-19 11:20:46, Qian Cai wrote:
> On Mon, 2019-05-13 at 16:04 +0200, Michal Hocko wrote:
> > On Mon 13-05-19 09:43:59, Qian Cai wrote:
> > > On Mon, 2019-05-13 at 14:41 +0200, Michal Hocko wrote:
> > > > On Sun 12-05-19 01:48:29, Qian Cai wrote:
> > > > > The linux-next commit ("x86, numa: always initialize all possible
> > > > > nodes") introduced a crash below during boot for systems with a
> > > > > memory-less node. This is due to CPUs that get onlined during SMP boot,
> > > > > but that onlining triggers a page fault in bus_add_device() during
> > > > > device registration:
> > > > > 
> > > > > 	error = sysfs_create_link(&bus->p->devices_kset->kobj,
> > > > > 
> > > > > bus->p is NULL. That "p" is the subsys_private struct, and it should
> > > > > have been set in,
> > > > > 
> > > > > 	postcore_initcall(register_node_type);
> > > > > 
> > > > > but that happens in do_basic_setup() after smp_init().
> > > > > 
> > > > > The old code had set this node online via alloc_node_data(), so when it
> > > > > came time to do_cpu_up() -> try_online_node(), the node was already up
> > > > > and nothing happened.
> > > > > 
> > > > > Now, it attempts to online the node, which registers the node with
> > > > > sysfs, but that can't happen before the 'node' subsystem is registered.
> > > > > 
> > > > > Since kernel_init() is running by a kernel thread that is in
> > > > > SYSTEM_SCHEDULING state, fixed this by skipping registering with sysfs
> > > > > during the early boot in __try_online_node().
> > > > 
> > > > Relying on SYSTEM_SCHEDULING looks really hackish. Why cannot we simply
> > > > drop try_online_node from do_cpu_up? Your v2 remark below suggests that
> > > > we need to call node_set_online because something later on depends on
> > > > that. Btw. why do we even allocate a pgdat from this path? This looks
> > > > really messy.
> > > 
> > > See the commit cf23422b9d76 ("cpu/mem hotplug: enable CPUs online before
> > > local
> > > memory online")
> > > 
> > > It looks like try_online_node() in do_cpu_up() is needed for memory hotplug
> > > which is to put its node online if offlined and then hotadd_new_pgdat()
> > > calls
> > > build_all_zonelists() to initialize the zone list.
> > 
> > Well, do we still have to followthe logic that the above (unreviewed)
> > commit has established? The hotplug code in general made a lot of ad-hoc
> > design decisions which had to be revisited over time. If we are not
> > allocating pgdats for newly added memory then we should really make sure
> > to do so at a proper time and hook. I am not sure about CPU vs. memory
> > init ordering but even then I would really prefer if we could make the
> > init less obscure and _documented_.
> 
> I don't know, but I think it is a good idea to keep the existing logic rather
> than do a big surgery

Adding more hacks just doesn't make the situation any better.

> unless someone is able to confirm it is not breaking NUMA
> node physical hotplug.

I have a machine to test whole node offline. I am just busy to prepare a
patch myself. I can have it tested though.

-- 
Michal Hocko
SUSE Labs

