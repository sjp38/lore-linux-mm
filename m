Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C94D8C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:18:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 832F621655
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:18:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="JEAD13h0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 832F621655
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FEC28E0002; Fri, 21 Jun 2019 09:18:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AF198E0001; Fri, 21 Jun 2019 09:18:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19DD68E0002; Fri, 21 Jun 2019 09:18:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id EBCB68E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 09:18:01 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id p34so7876512qtp.1
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 06:18:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=6EZ0gR7z8Dh+/hnSQH7YpH2ogNmaNCPQh/J8NFRWbO0=;
        b=bNrNuyRD2tXTqjR/9Ds/lSnA3PJAu3WYpqeCJAkgwP2+XC0i+aiAg9Lepcisb6lPpQ
         9x5AkFemLlZlt2U84ugMjqJ0irFGLk7RVPpSTOckNLo3R/ZmDa1++eKFhOljq02jUGEp
         0zY6NZEgzUU1x3AlMov5jTvjR4OKV+7yUxzX6JwS9cY1KO2RIA3C2YmKdF7Rw6K9/H+w
         ef0Ry3zE4VSTKso6IlGrRHFnibuAG7SVYqcNVVm7rGR56v/O8Agx4LlL9mNOJ8uEoIUQ
         umHKMPvF4NgGv2bmkBI3mz9iEOSehof42Mgvw4E7BPt0orbVd1zpTSvkmMlghOi2Toao
         f5Pw==
X-Gm-Message-State: APjAAAWyKUFut69V2IH8YT0PN5/YLPJPjTALZgO5NnjB09xzO2AGTBPm
	pv0SwU7B3fCb0Uy7WG0uoVqwmY1KWTLUQvkZbuiqL3h1ORKw4WhXPBcZ/isGf5bTCk+ZAtanF1K
	yC0Cace/dLHAL50C69xkKm1dhj46BmyODNBFu++/cwl9e3Aa+6vyaYAKJnQboXPGB1g==
X-Received: by 2002:a37:a484:: with SMTP id n126mr5157153qke.366.1561123081684;
        Fri, 21 Jun 2019 06:18:01 -0700 (PDT)
X-Received: by 2002:a37:a484:: with SMTP id n126mr5157119qke.366.1561123081097;
        Fri, 21 Jun 2019 06:18:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561123081; cv=none;
        d=google.com; s=arc-20160816;
        b=xe+GpgyRxu5xTFg7omnrR7V6v1FlK/1GHN/WSLDc4rFanHA/rDOTw6RqyLutUsXfNW
         7FFIo2F2qSz4R06TMCfd8BoROSEnVW8/FWTZRo128VRaAFvTeiHNTyeUKuoZu8PcEt4y
         6YRZVLcLtGbgov25bibEtTFw3vusXiTZCpNs7ahNkQPTg0563LLc4btkW1djXIl8XLqV
         d+6Ra4dDJtwrDBfywd+K0kUCOFrO6d7Cw8DwcumxspMVCl5hP2NF4K6TvaaLkO+21Mog
         YL89ARtvEy9KIyGNW8ZTzueQDjL5aLNNPzuh/tvvVCMLSRYLShLsSS7GtQi7MWFmV0O6
         mGdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=6EZ0gR7z8Dh+/hnSQH7YpH2ogNmaNCPQh/J8NFRWbO0=;
        b=O3cFkMynmnuSqB0/n4shbbyskxIg0EZESOgakBhV61IRTsWzuo8kb1P9WFQaisHtsl
         fp1oWgY85OXmWTUfmmioVwmzDuLChdatr68xmeUHq/Ch8UBYxQCnoNksG5Y9UfdeDBni
         JixPrzud+p/9/6JrWFYNPG9tk6usj0SQ7KLMu3UwUO8vvIHVJR+47F+sk78qHR2u2su3
         BDxyCpnAa1vGGQYEf8YRL7fl+8/RsDE59PEzRYwxvnHCYIddoOqr5SeotP7F6kvwpWXS
         iVTlTVduJZMUn9aGrmNm759mNxhn0yJEQEB2VaGZpwTaBnNdMr2+wfNLkl6V3OCyy2Uv
         w7Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=JEAD13h0;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u17sor4091132qtk.19.2019.06.21.06.18.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 06:18:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=JEAD13h0;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=6EZ0gR7z8Dh+/hnSQH7YpH2ogNmaNCPQh/J8NFRWbO0=;
        b=JEAD13h0TLm9EB6aYZve86G8r9dnXpPGF8CZQ9cJZ/pmdZ8X73ahqqdYrx+ynsrWS3
         6vyG2hgSQIvDnKzABjXST9Cuhz0U1lKAWTGacv//r09wHPvRuexSrP7Hl5I6a2PbOeAC
         +eeFA+7wm0KAq8GWFLu1Fxg4CnmMfMBSjuJIzCWvMvtk8AOcUGeOkCXKVdrtu4P33B9T
         dV+WeXbPRiJaRgQ9SQ2oghzrrd2M9BUmFuGynVrbyJkj/6rjeMJ0vl+rLR4Ne4FtqxZo
         KfTiPx+wirhg8c1tdHHIPJR5vsyxYy0mCAQgtzKcY9WYWQZJHCXpT3MyYKoEgCXbFLTU
         x1/g==
X-Google-Smtp-Source: APXvYqxSqZAXWNDzloJvhsgvJUwDefEESXhZFAG3jCaHWEdp5PRedaS9loqp7FD/hfEgnf2ddggbFg==
X-Received: by 2002:ac8:2734:: with SMTP id g49mr89550088qtg.228.1561123080778;
        Fri, 21 Jun 2019 06:18:00 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id 2sm1789423qtz.73.2019.06.21.06.17.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 06:18:00 -0700 (PDT)
Message-ID: <1561123078.5154.41.camel@lca.pw>
Subject: Re: [PATCH -next v2] mm/hotplug: fix a null-ptr-deref during NUMA
 boot
From: Qian Cai <cai@lca.pw>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, brho@google.com, kernelfans@gmail.com, 
	dave.hansen@intel.com, rppt@linux.ibm.com, peterz@infradead.org, 
	mpe@ellerman.id.au, mingo@elte.hu, osalvador@suse.de, luto@kernel.org, 
	tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Fri, 21 Jun 2019 09:17:58 -0400
In-Reply-To: <20190513124112.GH24036@dhcp22.suse.cz>
References: <20190512054829.11899-1-cai@lca.pw>
	 <20190513124112.GH24036@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Sigh...

I don't see any benefit to keep the broken commit,

"x86, numa: always initialize all possible nodes"

for so long in linux-next that just prevent x86 NUMA machines with any memory-
less node from booting.

Andrew, maybe it is time to drop this patch until Michal found some time to fix
it properly.

On Mon, 2019-05-13 at 14:41 +0200, Michal Hocko wrote:
> On Sun 12-05-19 01:48:29, Qian Cai wrote:
> > The linux-next commit ("x86, numa: always initialize all possible
> > nodes") introduced a crash below during boot for systems with a
> > memory-less node. This is due to CPUs that get onlined during SMP boot,
> > but that onlining triggers a page fault in bus_add_device() during
> > device registration:
> > 
> > 	error = sysfs_create_link(&bus->p->devices_kset->kobj,
> > 
> > bus->p is NULL. That "p" is the subsys_private struct, and it should
> > have been set in,
> > 
> > 	postcore_initcall(register_node_type);
> > 
> > but that happens in do_basic_setup() after smp_init().
> > 
> > The old code had set this node online via alloc_node_data(), so when it
> > came time to do_cpu_up() -> try_online_node(), the node was already up
> > and nothing happened.
> > 
> > Now, it attempts to online the node, which registers the node with
> > sysfs, but that can't happen before the 'node' subsystem is registered.
> > 
> > Since kernel_init() is running by a kernel thread that is in
> > SYSTEM_SCHEDULING state, fixed this by skipping registering with sysfs
> > during the early boot in __try_online_node().
> 
> Relying on SYSTEM_SCHEDULING looks really hackish. Why cannot we simply
> drop try_online_node from do_cpu_up? Your v2 remark below suggests that
> we need to call node_set_online because something later on depends on
> that. Btw. why do we even allocate a pgdat from this path? This looks
> really messy.
> 
> > Call Trace:
> >  device_add+0x43e/0x690
> >  device_register+0x107/0x110
> >  __register_one_node+0x72/0x150
> >  __try_online_node+0x8f/0xd0
> >  try_online_node+0x2b/0x50
> >  do_cpu_up+0x46/0xf0
> >  cpu_up+0x13/0x20
> >  smp_init+0x6e/0xd0
> >  kernel_init_freeable+0xe5/0x21f
> >  kernel_init+0xf/0x180
> >  ret_from_fork+0x1f/0x30
> > 
> > Reported-by: Barret Rhoden <brho@google.com>
> > Signed-off-by: Qian Cai <cai@lca.pw>
> > ---
> > 
> > v2: Set the node online as it have CPUs. Otherwise, those memory-less nodes
> > will
> >     end up being not in sysfs i.e., /sys/devices/system/node/.
> > 
> >  mm/memory_hotplug.c | 12 ++++++++++++
> >  1 file changed, 12 insertions(+)
> > 
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index b236069ff0d8..6eb2331fa826 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -1037,6 +1037,18 @@ static int __try_online_node(int nid, u64 start, bool
> > set_node_online)
> >  	if (node_online(nid))
> >  		return 0;
> >  
> > +	/*
> > +	 * Here is called by cpu_up() to online a node without memory from
> > +	 * kernel_init() which guarantees that "set_node_online" is true
> > which
> > +	 * will set the node online as it have CPUs but not ready to call
> > +	 * register_one_node() as "node_subsys" has not been initialized
> > +	 * properly yet.
> > +	 */
> > +	if (system_state == SYSTEM_SCHEDULING) {
> > +		node_set_online(nid);
> > +		return 0;
> > +	}
> > +
> >  	pgdat = hotadd_new_pgdat(nid, start);
> >  	if (!pgdat) {
> >  		pr_err("Cannot online node %d due to NULL pgdat\n", nid);
> > -- 
> > 2.20.1 (Apple Git-117)
> 
> 

