Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D62F5C46460
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 12:41:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94EC6208CB
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 12:41:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94EC6208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FD476B0292; Mon, 13 May 2019 08:41:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AD436B0293; Mon, 13 May 2019 08:41:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 179D86B0294; Mon, 13 May 2019 08:41:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BEDFF6B0292
	for <linux-mm@kvack.org>; Mon, 13 May 2019 08:41:15 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e21so17796236edr.18
        for <linux-mm@kvack.org>; Mon, 13 May 2019 05:41:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=B3/5KVxcV14Z3CNwkL8+C4WdthZw+XLxneP2GR8JpAA=;
        b=alQ9y8hBckKYXqF/9KA866pq4C8UkdAjYD8qqKObJ2i61cc3XTK1i/RPOW7zz8JNhY
         +OazHaX5pKKZe5JO00R1N5hZafVSil8GfHyDAMK9oPEn3nqTfyZm7ni3E/3t8D5nmNT1
         ghzqt4KHQ4XBwpsQiDj+nFSzo7RUP4FjXJZdxPmdqRV8TUn8p3OdkZ5Y0VBV93dSbNkG
         g3DSixTSCQs5Bw/dy0wmcbtd0t5xYx5RLMwipd8fEzxsfHLAdkfORQcNvDPL2Z8jgNmo
         u2rea3BhSG+Do9WxsnjxzjItIsRlLTo44QGHWikIGndSjl8+EK4Er8QlskHdGoaJAjPS
         QhdQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX3ilF24B5t3WHowOqqCCh7JaH/cWarG1At/Jzvi46xrHQOfPVl
	/bwgy+6wE+h8jOpXSXYtG/MHbCfc+gS+SA24XxzXuAJKUsHwPImoIEoi44huB+JpfOaQgqK6mFs
	o8zDrVCSt7WAOJ2xVwpvw6sn0rNvIeLkfqiKlhYYBm6cekUOjSRXy0DPZUHDcqZw=
X-Received: by 2002:a50:9470:: with SMTP id q45mr29301229eda.269.1557751275348;
        Mon, 13 May 2019 05:41:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy39Ui8sOqUpfo0sJtXyHbYjtt0TYTXeGyIVXcYR529BQuJPic2d4BgQ13RFTOb8DjejJcQ
X-Received: by 2002:a50:9470:: with SMTP id q45mr29301156eda.269.1557751274453;
        Mon, 13 May 2019 05:41:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557751274; cv=none;
        d=google.com; s=arc-20160816;
        b=dpUKtIfn+4JmlB855ylaK2KRK2nh2XeNdX6eAUCgrVb/3NLAgpaEV5GDzwI/GN73IN
         oYTAHp0MaGRsD7yj9slU+kbHgNQvPzpD7gUCBhVjuTiIRSPkGvYTMhWd5XDMYANuvNFx
         xkFuEOE9icwsqxHXeJbebNte3JrjNnba/Os1C5PHr9eE/888bqPBIK9JsQDoitU/q9fy
         7/KXfeqURaj1dApnvsldrVHfsmpV6ASznazE48EEWG3Tg8GxIFuboV7THIocZUGWEbmf
         zHSvBCbWWjtrUHbLwwxHxQNL9jkahAsmZ7eQgNH5Hrkd9qjIvR6qVB194LcNN5iWSvtj
         rFdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=B3/5KVxcV14Z3CNwkL8+C4WdthZw+XLxneP2GR8JpAA=;
        b=URK48zChk2c9rnyG0O/PtwNK+d28Z9BmW9uvUi5VgLzLcXuHbtGNSKaNOw53RwF2vf
         wuZI3lbGAWDgF6YeIbwe+vYq/4uLTuyzFYhEW6Z8cwTvEe2YXl5hka1TA9XN+X7sAXAX
         VmjUu1qS0ApPYanfjDqut3I8EqoX9/8JRy06hz/DS9lHxIHuoZojAYRFKNeXQWr9ldYn
         38u5rBK4VzAzLGTLhwx6n4dBPIm4wT9FtAPHOK+b6DwhOKTSaq3U3o/uEN1QqPJqk8tx
         p+iqWJ1/ooR+HRCGCF3cSstv6+76m7H03Xwpch3XCCgVL7tXddCCx89ZjoUhIvW3GYf+
         pBZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f19si2551133ejr.194.2019.05.13.05.41.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 05:41:14 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9A2D7AF60;
	Mon, 13 May 2019 12:41:13 +0000 (UTC)
Date: Mon, 13 May 2019 14:41:12 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, brho@google.com, kernelfans@gmail.com,
	dave.hansen@intel.com, rppt@linux.ibm.com, peterz@infradead.org,
	mpe@ellerman.id.au, mingo@elte.hu, osalvador@suse.de,
	luto@kernel.org, tglx@linutronix.de, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH -next v2] mm/hotplug: fix a null-ptr-deref during NUMA
 boot
Message-ID: <20190513124112.GH24036@dhcp22.suse.cz>
References: <20190512054829.11899-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190512054829.11899-1-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun 12-05-19 01:48:29, Qian Cai wrote:
> The linux-next commit ("x86, numa: always initialize all possible
> nodes") introduced a crash below during boot for systems with a
> memory-less node. This is due to CPUs that get onlined during SMP boot,
> but that onlining triggers a page fault in bus_add_device() during
> device registration:
> 
> 	error = sysfs_create_link(&bus->p->devices_kset->kobj,
> 
> bus->p is NULL. That "p" is the subsys_private struct, and it should
> have been set in,
> 
> 	postcore_initcall(register_node_type);
> 
> but that happens in do_basic_setup() after smp_init().
> 
> The old code had set this node online via alloc_node_data(), so when it
> came time to do_cpu_up() -> try_online_node(), the node was already up
> and nothing happened.
> 
> Now, it attempts to online the node, which registers the node with
> sysfs, but that can't happen before the 'node' subsystem is registered.
> 
> Since kernel_init() is running by a kernel thread that is in
> SYSTEM_SCHEDULING state, fixed this by skipping registering with sysfs
> during the early boot in __try_online_node().

Relying on SYSTEM_SCHEDULING looks really hackish. Why cannot we simply
drop try_online_node from do_cpu_up? Your v2 remark below suggests that
we need to call node_set_online because something later on depends on
that. Btw. why do we even allocate a pgdat from this path? This looks
really messy.

> Call Trace:
>  device_add+0x43e/0x690
>  device_register+0x107/0x110
>  __register_one_node+0x72/0x150
>  __try_online_node+0x8f/0xd0
>  try_online_node+0x2b/0x50
>  do_cpu_up+0x46/0xf0
>  cpu_up+0x13/0x20
>  smp_init+0x6e/0xd0
>  kernel_init_freeable+0xe5/0x21f
>  kernel_init+0xf/0x180
>  ret_from_fork+0x1f/0x30
> 
> Reported-by: Barret Rhoden <brho@google.com>
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
> 
> v2: Set the node online as it have CPUs. Otherwise, those memory-less nodes will
>     end up being not in sysfs i.e., /sys/devices/system/node/.
> 
>  mm/memory_hotplug.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index b236069ff0d8..6eb2331fa826 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1037,6 +1037,18 @@ static int __try_online_node(int nid, u64 start, bool set_node_online)
>  	if (node_online(nid))
>  		return 0;
>  
> +	/*
> +	 * Here is called by cpu_up() to online a node without memory from
> +	 * kernel_init() which guarantees that "set_node_online" is true which
> +	 * will set the node online as it have CPUs but not ready to call
> +	 * register_one_node() as "node_subsys" has not been initialized
> +	 * properly yet.
> +	 */
> +	if (system_state == SYSTEM_SCHEDULING) {
> +		node_set_online(nid);
> +		return 0;
> +	}
> +
>  	pgdat = hotadd_new_pgdat(nid, start);
>  	if (!pgdat) {
>  		pr_err("Cannot online node %d due to NULL pgdat\n", nid);
> -- 
> 2.20.1 (Apple Git-117)

-- 
Michal Hocko
SUSE Labs

