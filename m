Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D93A8C76194
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 06:13:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A89DA20840
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 06:13:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A89DA20840
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25B128E0003; Sat, 27 Jul 2019 02:13:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E3DE8E0002; Sat, 27 Jul 2019 02:13:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 121678E0003; Sat, 27 Jul 2019 02:13:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id D490A8E0002
	for <linux-mm@kvack.org>; Sat, 27 Jul 2019 02:13:57 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id f16so26760828wrw.5
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 23:13:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=tX9yCo7NLQ2p9PYQ1sTnjao9+GvWXndXz2bYIrGw+Y4=;
        b=BikyzTkXcHNPNEsR6SxmYnqEm9q0vs47T9EPc6uof9nEu3RDM20wfUXScpk6TFrX/d
         v++bLF1GjiLSaV4pSi8Z8PPl2sBwg9JME6Wm3aXXhJ+oqYWDI/L13Ff38Tiv+YFod/NL
         tKFDh+YTuDk4O3KckZBj1jdNwvwl7JZw2ghSU6NqjoKuTLqm2LwrYAj1AFBH/lgne9be
         GWfEZt0fVkthr+1klqWBGKRTg1uHKsQVv5bkZ8kvUZKuQ+6kGeHCLzvyhR87Q7EQeCSU
         uyvBaE5XU3mYF+vuCIpWbbDJGJnhASahG+mWTrZrDWRNKghMXdBNqIcsslQPad6fkQ6z
         4kLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAUOMlE7/v40OtOIvRCQ6TSy+bquRDgqkFpPmOtlS84Bb235PcKh
	KOgQ1inunqJIVZOfh5sK+IljY7QbEJJSGmPuIwRq7PerwKl9cxf53s/E9wLnoixHK/qCz4TutKX
	9Jl0Z3eyDShOShr2j97CpOqsHvk1ZLBlF22yyfzhjiNixzY2gmorhajGi9zduXoOtKg==
X-Received: by 2002:a1c:c145:: with SMTP id r66mr88453738wmf.139.1564208037386;
        Fri, 26 Jul 2019 23:13:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykJ6rHpYNxw63vQtiAs8pSJ8PlHJWCaPyjwvtwdZXpEvfhCBEB0nbqA0ySz6WtgJRnQTId
X-Received: by 2002:a1c:c145:: with SMTP id r66mr88453673wmf.139.1564208036649;
        Fri, 26 Jul 2019 23:13:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564208036; cv=none;
        d=google.com; s=arc-20160816;
        b=A4aHuMkuyrWEuOe3Stls/8kPvzpzlBLwbJa6W6eUY6niyGWucjHVb2A1gHwCoxlFZ8
         C7vyuTNPGJAYBA5JYXqBYBFL95d7AAC1f968QHUURY4Ad06TV++Nzl3oK7eMa7/0XyNt
         +nPaIh78YC5fmHDVQovZ9kEVmYqnwNccTiMzz1jmjxSSvEXVDXMcr8AAvGzcV6xQX1bR
         fuLJZ8zoA5bs8Yup9dujAut/hO52agk9Ew0KVOPfVx9Xu6oMlLh04qqTRHQMeWhri/2Q
         JzoHjneVh1zUoScoaH8+w3WA8B3GadcT+urGX2o+k0ek4kQrA45ZlNJke+iG3ZLSzI6Q
         jWiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=tX9yCo7NLQ2p9PYQ1sTnjao9+GvWXndXz2bYIrGw+Y4=;
        b=q80p1yOMCoWTqwgrJd31x9FDPSK0O92Kwh1EC0GRNryLhErqF57IzDeOPusBno/vr6
         rZtWrGDPV66t95RC58sweEyhy/lBNVVLeMuupRqopziEcbxtl6dlLpNweuteDlgn/dro
         Pt+LKnklFpDtPX21qwsF5br79l36XBwTjTWfl+hglQZ8pRpjdIoszOyyZamKP9YjHaqJ
         fmk1EW8dFkhl3UdhxhJf7nZFAsr0bgawH82rwmftLXcW9RBzS2SfiB0t98wbz/ltryXp
         zTTfL7rAvE1xMEYF/dT7Sa2ltLTdvnP0cOhH4BBJiZ0Y38DkpcDLeX3hzR78LdgJiqec
         xFIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id v132si42747611wme.167.2019.07.26.23.13.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 26 Jul 2019 23:13:56 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef1cb8.dip0.t-ipconnect.de ([217.239.28.184] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hrFxp-0000c9-4B; Sat, 27 Jul 2019 08:13:53 +0200
Date: Sat, 27 Jul 2019 08:13:51 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, 
    linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, 
    linux-mm@kvack.org
Subject: Re: [PATCH 2/7] vmpressure: Use spinlock_t instead of struct
 spinlock
In-Reply-To: <20190726155033.d10771437e26dd5007f91a08@linux-foundation.org>
Message-ID: <alpine.DEB.2.21.1907270813370.1791@nanos.tec.linutronix.de>
References: <20190704153803.12739-1-bigeasy@linutronix.de> <20190704153803.12739-3-bigeasy@linutronix.de> <alpine.DEB.2.21.1907261409260.1791@nanos.tec.linutronix.de> <20190726155033.d10771437e26dd5007f91a08@linux-foundation.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jul 2019, Andrew Morton wrote:
> On Fri, 26 Jul 2019 14:09:50 +0200 (CEST) Thomas Gleixner <tglx@linutronix.de> wrote:
> 
> > On Thu, 4 Jul 2019, Sebastian Andrzej Siewior wrote:
> > 
> > Polite reminder ...
> 
> Already upstream!

Ooops.

