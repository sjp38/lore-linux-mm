Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 288E7C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 12:04:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D84BE2192D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 12:04:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D84BE2192D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86A0C6B0003; Fri, 22 Mar 2019 08:04:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F15E6B0005; Fri, 22 Mar 2019 08:04:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B9B86B0006; Fri, 22 Mar 2019 08:04:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8B06B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 08:04:48 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l19so857911edr.12
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 05:04:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=I0K+IzYYrrOWQ3m2GnTDJ8trQi+motXSSkNAW3hne5s=;
        b=kwUfFrSh+LEAcVchK2KI8KqPFYg84St/SsSBw1OtGJgAQfls5r1KkczYF7EAB/6Cj+
         Ea/jhxdGzAaBYGej/F72JLcvgjj0CXNv8gdGmk7zamTCUwL6vExOSGrPJm6kyDqmboNW
         3MZXb0eLMKwrdzlkeEbazUwfZ52//UhOOUDuS+lvMQWl3leuyqg9q/nmX6r4w4BocnPe
         9rsRnMnyNwwjJyDHvQphqdArboNXlP2MvPzSuyAsbrP6WovQzD3UJTyNC+CePUMsaWI/
         MeUquq1b/PbsJnjBu122zNvVIPJghJdNC79l/tObDla59gk1nCdvaSVS3dCL2fHXEFeG
         S7DA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXp/jPRo4a7Wim+yExgFzIFdV7Of52Tds0+EFvoV+dE8aB+n0kb
	fdROeTGs6k9HK3NoTDgWgSEJ7HKpnMxQmRspFEf7wa030L0QeodwNmYuxueianMSSmgtpftyakR
	XMiMFaSdt+8jj+1g5s9B4jLyik8+rky3P7ByIu485Bgtmg4+AI21rlBiW/YoHMwhhsw==
X-Received: by 2002:a17:906:4017:: with SMTP id v23mr5396789ejj.40.1553256287635;
        Fri, 22 Mar 2019 05:04:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnvxlxSvu9HKccMOJNvbBAoz+Z3lQwnG1NNita3MzA9Fb6Egtn1duI5nnrw1ERRQKV5gLA
X-Received: by 2002:a17:906:4017:: with SMTP id v23mr5396740ejj.40.1553256286698;
        Fri, 22 Mar 2019 05:04:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553256286; cv=none;
        d=google.com; s=arc-20160816;
        b=xiyrj1wRi4KO3aGlSkLT4XJx8u0tpCq8dnRRuNS8NErI9sJK7mnqWsuj4YL3d9yzsx
         XSBtCiQEG/xjdgVX/OK1i0tNJwnwW2aISDD2zcPOlT+tNNmf4iD4nqDKD8COsS5QXVev
         5aUAWQcamR3nKXTuO/DzNu0WBzyPT+NpVZXceWI5F1idlLtyzIhsNR+4/l6YOQ6jULC8
         dUJUY0dPVQf0eubhP2rLgJiQqqSV4UBarr29TttFn9UdAMTAVv2ukVZJ3f6Wp3fD9fml
         TdwnfyK6F02Nth3BAx0Kzzip3C10lbRWT50ae9hTaqP8FDT13PUOs1obnguloZga3eS4
         iTWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=I0K+IzYYrrOWQ3m2GnTDJ8trQi+motXSSkNAW3hne5s=;
        b=OTG+IuvErxOOlifVFzFiCTDkK/iq7ofnrEhJ14qUicfIODrvnc63JBYw+3E6zHFPOv
         0vem83JgOZPdZvsRQJcfA0nhrysNB7msd0v/TqHUlJUdGB1/16rINSUyF/6d+Wed+1E4
         m7fRV3HjHCAjZbNquElqPVLaWoaS7nnIP5X57aPE97+womQkKVJ1oNVszz2X4uhBHlJO
         DdAOkP4Sm5yDJhk+J1VoYm1z//i0vzcA5NaaLR8Axf1L6khqcHyFLzV5X2BJjWww2p82
         U8OENrZu7IsXtKOP0Tx19jLgEi8KLOAnJVuS0BivtfNMDS72VXcMPCVlO/0wOTF4FgWz
         fm/w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p15si1550005eda.168.2019.03.22.05.04.46
        for <linux-mm@kvack.org>;
        Fri, 22 Mar 2019 05:04:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6BE39374;
	Fri, 22 Mar 2019 05:04:45 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AAD963F614;
	Fri, 22 Mar 2019 05:04:37 -0700 (PDT)
Date: Fri, 22 Mar 2019 12:04:35 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	bpf@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v13 09/20] net, arm64: untag user pointers in
 tcp_zerocopy_receive
Message-ID: <20190322120434.GD13384@arrakis.emea.arm.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <2280b62096ce1fa5c9e9429d18f08f82f4be1b0b.1553093421.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2280b62096ce1fa5c9e9429d18f08f82f4be1b0b.1553093421.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 03:51:23PM +0100, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> tcp_zerocopy_receive() uses provided user pointers for vma lookups, which
> can only by done with untagged pointers.
> 
> Untag user pointers in this function.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  net/ipv4/tcp.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 6baa6dc1b13b..855a1f68c1ea 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1761,6 +1761,8 @@ static int tcp_zerocopy_receive(struct sock *sk,
>  	if (address & (PAGE_SIZE - 1) || address != zc->address)
>  		return -EINVAL;
>  
> +	address = untagged_addr(address);
> +
>  	if (sk->sk_state == TCP_LISTEN)
>  		return -ENOTCONN;

I don't think we need this patch if we stick to Vincenzo's ABI
restrictions. Can zc->address be an anonymous mmap()? My understanding
of TCP_ZEROCOPY_RECEIVE is that this is an mmap() on a socket, so user
should not tag such pointer.

We want to allow tagged pointers to work transparently only for heap and
stack, hence the restriction to anonymous mmap() and those addresses
below sbrk(0).

-- 
Catalin

