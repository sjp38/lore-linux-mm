Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27E6AC76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:47:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3E882171F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:47:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3E882171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 830B06B0003; Mon, 22 Jul 2019 11:47:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E2078E0018; Mon, 22 Jul 2019 11:47:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 683578E000E; Mon, 22 Jul 2019 11:47:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4636E6B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:47:37 -0400 (EDT)
Received: by mail-ua1-f72.google.com with SMTP id t24so3745301uar.18
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:47:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=LmHNB/mpVTqIwDQayKoNtK91EYT50XXRmgPJE4A3zfc=;
        b=t4+yEU4BntkNSO4NMcs4+QDn+alzW17LQwQb43JnDfsMana1ZHNHTilulwjPeBfpaA
         iPkFP2cRuSq6wQ53ZyFSIVmmIvinbsLdpzT3IOW5fuwfpQIkJBb2iU0p/lYXOD08146g
         P5Twxb2Bv52i0DJOjtw8eAx3XolS4iXpXfi8CwYChNSj0IuBHbJkMeuEchE4lixbsnXw
         iiAjTrpU+YtlBv7O/zZzfPtVZtwWzRRng9n3o7rAx0Rsc81GD6b92ChON0xXLNTQBiNx
         0kSXvc4+kjgUohVSbWwkEYlH6t4TMbHWc0XsGYSkkrRDQt2yjcqww3BkhZNCs19bvS0y
         Nrxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWwOMHfxIhuAqhFipmQHrtRO/T0tCixzfpZvrJP10g5MYimYJK3
	GRWGZmlFVePG5CAbOldY6zZzpVvm/P26PWKBcPsSPEGM9Pj+Ygr8Yanzx6NEXBK9kW2gH6yhauL
	XTJUSXaURhjIa0d6mwjnbWJbKRvysgTgktaHXYF4TZvR/rr8zXTxx4eFivf4nMSGB3w==
X-Received: by 2002:ab0:2746:: with SMTP id c6mr1616183uap.76.1563810456947;
        Mon, 22 Jul 2019 08:47:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztTk+IamiBfVkYB3jVP/zjMjwRdU11pur9aY+PowzkzG4KBY3yTiapmrZfqcRNHTJAFaNz
X-Received: by 2002:ab0:2746:: with SMTP id c6mr1616134uap.76.1563810456346;
        Mon, 22 Jul 2019 08:47:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810456; cv=none;
        d=google.com; s=arc-20160816;
        b=NmWXFGcucAod5s/BXu7sNhEp2HQbHOkp6LmbjCn5BkjAm0RtGznpbkg+0P/ZLayujX
         ZE3omkGhFjuPB1p1YIiHKH7oxnBvQ3kUsr6RIm1NLA8b0h34xTG7Ai8crggvdjDXopHR
         h3Oxge/6p9t4OWzi3JovAW6sziGl1V2Zxmdo3tJsf6uJbLp6gUUkmzxamoGgNE7ICBXK
         65CN1ewUrHI+3mT7hv4wlb9MsJwKxQaCkYMWxHYIp9mI76t55t0RHOMkLyg7XwR3qYtY
         e+GjbbzofMC6f8PTL9lQwBMpHFzM+ktuhipFsiiHilPVAWq3DclsnHGUcDvQkPoMFsCq
         2jhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=LmHNB/mpVTqIwDQayKoNtK91EYT50XXRmgPJE4A3zfc=;
        b=Fx/fa3t4Pufrm9G9R7X/PvWhYPGue7c4EpcdV0fZx95IYfALiEJUFHoZs8L/ND143Q
         MGhhWBB1YRK7gQexEquOZYon1Ra2u01aHOJvDIeZLlSXIZgiUwqq7sS28le5JfhUS64V
         MWbr+6XQif8T94oLsLmI5GK3yPdcPBEwU3eZONmWlnzKrF0WKCrVv/sZwEhMt/o2r0gW
         Vu4JX5AU9lTT+5A74gAC5BgchaRjoO82Rtm9CsOBxGHYgyxom5WOq/oeM7vbypOubbl2
         hkbyNHF1I/6ylYnsbuIyhzlylXTgRNUTsX9I+JITQMk9qy7DVuBH+jNKVfqhc+O41FWu
         sq8g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w29si7981878uae.204.2019.07.22.08.47.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 08:47:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0CE75C058CBD;
	Mon, 22 Jul 2019 15:47:35 +0000 (UTC)
Received: from redhat.com (ovpn-124-54.rdu2.redhat.com [10.10.124.54])
	by smtp.corp.redhat.com (Postfix) with SMTP id C428460603;
	Mon, 22 Jul 2019 15:47:25 +0000 (UTC)
Date: Mon, 22 Jul 2019 11:47:24 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: "Paul E. McKenney" <paulmck@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>, aarcange@redhat.com,
	akpm@linux-foundation.org, christian@brauner.io,
	davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jasowang@redhat.com,
	jglisse@redhat.com, keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: Re: RFC: call_rcu_outstanding (was Re: WARNING in __mmdrop)
Message-ID: <20190722114612-mutt-send-email-mst@kernel.org>
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <20190721081933-mutt-send-email-mst@kernel.org>
 <20190721131725.GR14271@linux.ibm.com>
 <20190721210837.GC363@bombadil.infradead.org>
 <20190721233113.GV14271@linux.ibm.com>
 <20190722151439.GA247639@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722151439.GA247639@google.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Mon, 22 Jul 2019 15:47:35 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 11:14:39AM -0400, Joel Fernandes wrote:
> [snip]
> > > Would it make sense to have call_rcu() check to see if there are many
> > > outstanding requests on this CPU and if so process them before returning?
> > > That would ensure that frequent callers usually ended up doing their
> > > own processing.
> 
> Other than what Paul already mentioned about deadlocks, I am not sure if this
> would even work for all cases since call_rcu() has to wait for a grace
> period.
> 
> So, if the number of outstanding requests are higher than a certain amount,
> then you *still* have to wait for some RCU configurations for the grace
> period duration and cannot just execute the callback in-line. Did I miss
> something?
> 
> Can waiting in-line for a grace period duration be tolerated in the vhost case?
> 
> thanks,
> 
>  - Joel

No, but it has many other ways to recover (try again later, drop a
packet, use a slower copy to/from user).

-- 
MST

