Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AE9FC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 14:05:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 197F42173C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 14:05:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="0Cj5ef94"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 197F42173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97AFF6B0003; Thu, 28 Mar 2019 10:05:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 931826B0007; Thu, 28 Mar 2019 10:05:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F2AF6B0010; Thu, 28 Mar 2019 10:05:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 51A3A6B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 10:05:41 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id k21so17620931qkg.19
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 07:05:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=OZsN+KjF6P0mNOSjgzFw3fqkoVmkhJo6T0apoMNZd18=;
        b=c29RF/EOlPxqm1LgQc2SAUjOt0jdVx4Ql+bJP8YBbw5ZNxx2lKg3c9vFUgq77MbZe4
         bLCnWKidwyhGAgeAa0wCyE7Tw1cZor1bnEqjvPMKYGKQ6/oPie5iSdJLZHPugrnfCA0/
         HdL0WOCslkR9TuKe/xvsRv2D8u9SF1x4WotFNKTMn3ESsH+mVTarS4Aoygp6Nek8iz61
         JA/IZNPazf7L5vWoo0b8uc5G+e6VX+o/93/i6VVfQeu7+HulzOhaENgPjVi/nV8B2wEW
         zjlqUjaG5PmFPvcPiWF0K2kbtKrB9SSItSK6wU26yvXLeWSFfxl96FvG/v0Y9VlfTLbI
         eeyA==
X-Gm-Message-State: APjAAAXp0rTf6G7Eblc77pZ4oaR3dhf6JiFhfrhosp4TVQr+4MYfn9nN
	t1Cnmnlrtsr6n7w2x6hsN3Ihsg8hOJjzVB3g8F60vubkr/YODVeTCOLjGcoqBv2qvkxtRYAebGK
	1KgFe7eGvMJpn3pdlfmhBJ5+j5GmeVWJHS5ImxBLG96NX/7Qhl2fNNUmjgzjlvn81Rw==
X-Received: by 2002:ae9:ebcf:: with SMTP id b198mr18557287qkg.129.1553781941003;
        Thu, 28 Mar 2019 07:05:41 -0700 (PDT)
X-Received: by 2002:ae9:ebcf:: with SMTP id b198mr18557205qkg.129.1553781940009;
        Thu, 28 Mar 2019 07:05:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553781940; cv=none;
        d=google.com; s=arc-20160816;
        b=SO8tuDHxeWDUegzp0erqRfl1V5N/nN2BJTmJT9Pk3r5so3zaVJnZ5sa0OVPZ1tjZx5
         LpUIngLf2hjuN2x/ptzDs23Cj7t3dS1K1YicAUmHbC0PR/8zIfl6bn0LtHQzHay2lwub
         eg56CItv1uG7hZGLG2dgobZhWf317pyLr7Sve5J44bH+TkM4jD94ILN1yGqitXXO+uz1
         tVzY/jV9J+syDH+9gC2m0o75SNWQ1mHc6qht42WDvMA2aiqwZJv/dtPX8pnlwGwmKKWv
         1lngXSvrx9+41bmKx7fbv+gbSwCXHv0ZbeTUt9morwsXlywGiYSQG+PRU6zd/D3vzIAK
         cFwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=OZsN+KjF6P0mNOSjgzFw3fqkoVmkhJo6T0apoMNZd18=;
        b=ScNNbQSgaOZtXvnMy+qVOD0w6IFOTi5ypI87dHI2CehXWYBeIjgN25mTA5I1jMSsti
         //FWL0oyOozmcybnO7jz7gckhYjPYhWHBwnCeLEwcYnRMN3oUj/QwaWKk+BLtY/kbXQ+
         THhgwgVGofDl45M+Yq9Rz6oi7vAC5Ma9JSiAaSc/cVqdschnFY52zEuw68bGdcNSwOr+
         DXB3TP3dmASjBtKub1OF7QItpkMQI6nUTqMQtwcC1ia0QcP+MPnVZVew0Rk9oKHc3xpe
         LsWqFHzHl4za5JT/+UdWcrr39e6quRYmdUuXPMGRP/h6YQSAPuFDQAhbY0jZ6ud7K0Vp
         dLqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=0Cj5ef94;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e36sor29806193qtb.9.2019.03.28.07.05.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Mar 2019 07:05:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=0Cj5ef94;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=OZsN+KjF6P0mNOSjgzFw3fqkoVmkhJo6T0apoMNZd18=;
        b=0Cj5ef94+CRYvijQ1AKj4UAqc1sd4cV79FVilXIDCXG80htX0gpXBVJh72zcQtcJlO
         83oIVfRWYgGi6lHslyDtBI3ISnwIp+M5c97aBdGGSBoOLO7P0Kq8VgRgXDXrDFSj6+Ly
         Fh1kQXuELevRdHZlCwh6RbGwkyggA16Rmaen1DQAvAgsDUxHHE4m5zGtKKuYRdDomMbS
         p/aamlRNU+LM7rc6ak7M6DGzDhKOv3Bos/DVp1U6uVikCyCEn5ZD5js8unIeQTNtJZZM
         TmQIYr/CClYewtDHXV+F6YqaE9UWtU8KTpv5bB3oZQlejMPBoKJYTh5o/oDASbqx/6V7
         Gx+g==
X-Google-Smtp-Source: APXvYqzhlNfyJWYewSPQn9Q2ZGgaGwby4p0a0N5/E0M0U5RjcC3vbzUObNwUIUTLX3Be4ykk3m8SjQ==
X-Received: by 2002:ac8:3fbc:: with SMTP id d57mr34297897qtk.96.1553781937336;
        Thu, 28 Mar 2019 07:05:37 -0700 (PDT)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id b37sm10221707qtb.92.2019.03.28.07.05.36
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 07:05:36 -0700 (PDT)
Date: Thu, 28 Mar 2019 10:05:35 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Greg Thelen <gthelen@google.com>
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Tejun Heo <tj@kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] writeback: sum memcg dirty counters as needed
Message-ID: <20190328140535.GA15622@cmpxchg.org>
References: <20190307165632.35810-1-gthelen@google.com>
 <20190322181517.GA12378@tower.DHCP.thefacebook.com>
 <CAHH2K0ZqTXhdA+RSZU0a4kjeJexQ5Kh+rMaspzhMCwjKjJvHug@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHH2K0ZqTXhdA+RSZU0a4kjeJexQ5Kh+rMaspzhMCwjKjJvHug@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 27, 2019 at 03:29:47PM -0700, Greg Thelen wrote:
> On Fri, Mar 22, 2019 at 11:15 AM Roman Gushchin <guro@fb.com> wrote:
> > On Thu, Mar 07, 2019 at 08:56:32AM -0800, Greg Thelen wrote:
> > > +     int cpu;
> > > +
> > > +     for_each_online_cpu(cpu)
> > > +             x += per_cpu_ptr(memcg->stat_cpu, cpu)->count[idx];
> > > +     if (x < 0)
> > > +             x = 0;
> > > +#endif
> > > +     return x;
> > > +}
> >
> > Also, isn't it worth it to generalize memcg_page_state() instead?
> > By adding an bool exact argument? I believe dirty balance is not
> > the only place, where we need a better accuracy.
> 
> Nod.  I'll provide a more general version of memcg_page_state().  I'm
> testing updated (forthcoming v2) patch set now with feedback from
> Andrew and Roman.

I'm working on a patch series that reworks the memcg_page_state() API
and by far the most callers do NOT need the exact numbers. So I'd ask
to please keep this a separate function so I don't have to update tens
of callsites to pass "false". Thanks!

