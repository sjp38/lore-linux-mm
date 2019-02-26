Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45FE1C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:03:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02EF520C01
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:03:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02EF520C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79F108E0003; Tue, 26 Feb 2019 12:03:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 725718E0001; Tue, 26 Feb 2019 12:03:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C85F8E0003; Tue, 26 Feb 2019 12:03:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2AD288E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:03:45 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id z64so3508081ywd.12
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:03:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AYQDhdjbYQUyfL+3XviMbb8a/BeQjAxJJtDJUDHwgLM=;
        b=HkLHS3JvajC/OJRfkZkhG+3jMeELYttPPrrbqu7ag6w1GP6ApYwVS8A2oMBqgQN0Pf
         5cq+4TZrayZNFxvwbChPeitQJqZ1lDjbtNeDoE1ENDKxVOF5m9fW0Z7XSm6R8z76WtjK
         WJjFJUW6AGodi8en+FdikDc7wri5p8UsDcja8gA6w45+9w6+aZL8VhqAIgYaqUS8Agac
         P02EnLBMQ3j/JbWNA5VSvD8o03eJem2GKjikKpjPC0gP7kl7MLUG972Hdq7FEFbBD4hq
         OvtBMOA1SUJR6ZAdBfB6c9TSLg+0gLHes6YtctiEjBD5J0f5e/RDCol3RANY+2JQqESL
         yg3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYQsdBBPO04sbNaNYCHfyiwz4Ha+/pMOU1/agvIY0MbVai8P8od
	h1I3RCSMD9ITzS5BNnfFvHiMXeSFll3PxMfVSZNt0RueWUu/GLmlSEhDJm6mqe9fRNW49GPr1JJ
	xSJg3HBjmlq+sPJTjaC7uUi+EoW6ZpLrfDEsYSWxiFAsIB5wOQxhLj9/oZ9MKHvoz6kM1kkL5Il
	xLO9LiSpjLZ2WLuhFanxpF6Q4qTLWwyPbvP3YkJMBNFps+LsCQcwMamIEU0h6trT7XrS58BAeph
	UV2Yi2iF7Y/UgO+3x8JewIsCW5Q4J4EZYt1iRWRT5Bf1CSAaT4SNBhX4q9GGq3/bsd1JJM7hfgD
	CWO6VO1aiOhtafPQ0f8kKIGB8iGHrRxc6jwY4r9vfFxw3oLn8z+clVAMosPxeYv2IqlZpg3FYw=
	=
X-Received: by 2002:a25:dd7:: with SMTP id 206mr7445580ybn.214.1551200624883;
        Tue, 26 Feb 2019 09:03:44 -0800 (PST)
X-Received: by 2002:a25:dd7:: with SMTP id 206mr7445468ybn.214.1551200623763;
        Tue, 26 Feb 2019 09:03:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551200623; cv=none;
        d=google.com; s=arc-20160816;
        b=TLKyeVbg9jNP2xkDarxyMM5HtOnwMYWTZ6BdAX5gr2z2rlGdvohohEjupjrDY6m2xA
         HzY8Gx3CDsuVPtd+mnidt2gVmkH3thiAP/9+evcOrteqo12UgHhAtvPuSwDE4grmxzHG
         b5r81f2iyyv4vsk9ftpMUzX1H2IYGfsSHZfsnaCBEkD0Q2G5ganzLAwSRgsbSMIQNjQB
         Y5fkFufMw79PgJx4JtnFs5SANhlgo+8+vqlQK4TkvSRYhTVhemn53xwQXY2YMFWgA0L8
         IVflelCEgfA8HEzm7wmjLgq6BWiJYfW2IuWdxnCyU3ae25+YKF3PILFiBT6e2vd3skCB
         0yNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AYQDhdjbYQUyfL+3XviMbb8a/BeQjAxJJtDJUDHwgLM=;
        b=fC1ChgxMOd/ghLSk74ce1rth56VvRd/BCUPY73NhpPtgxjOwP4uuNefvT2OfCIx76F
         8tbQ0THnUXWXOsiyoXsFKHKjAxyE5kYAoeivHIkEQ15VybJJrJ/+yxIclmuupRiq4i33
         mAQ7G87ekqeZ0g/BIKo7mW5wymuraVHOOBlx2k10JNi0cg+ZhzSDoD3m6fSuCsY6ytOt
         m6THfXIPHy2lc2cePUcFs5uQNN/0ZuZwPqgOWugqQU5whsBAEBRKHDCpXq+xk0SWc+L2
         xkccegzro2fvp+0oJiYZ9iHvcLrWERLLK6/G3TuesRS8fH93pww+a4f5IUTwSmpq8Lrf
         C3hw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y4sor6424454ybp.147.2019.02.26.09.03.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 09:03:43 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IbqGExLy62XrfPHcYlcJbEhfIUGhyPvfdWuLAX37FLp24NgOgc5mpag2drjeqrr1nXDyPE1Cg==
X-Received: by 2002:a25:d44c:: with SMTP id m73mr18018663ybf.349.1551200623043;
        Tue, 26 Feb 2019 09:03:43 -0800 (PST)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:200::2:7f17])
        by smtp.gmail.com with ESMTPSA id 207sm3527372ywm.67.2019.02.26.09.03.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 09:03:42 -0800 (PST)
Date: Tue, 26 Feb 2019 12:03:39 -0500
From: Dennis Zhou <dennis@kernel.org>
To: Christopher Lameter <cl@linux.com>
Cc: Peng Fan <peng.fan@nxp.com>, "tj@kernel.org" <tj@kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"van.freenix@gmail.com" <van.freenix@gmail.com>
Subject: Re: [PATCH 1/2] percpu: km: remove SMP check
Message-ID: <20190226170339.GB47262@dennisz-mbp.dhcp.thefacebook.com>
References: <20190224132518.20586-1-peng.fan@nxp.com>
 <20190225151330.GA49611@dennisz-mbp.dhcp.thefacebook.com>
 <010001692a612815-46229701-ea3f-4a89-8f88-0c74194ba257-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <010001692a612815-46229701-ea3f-4a89-8f88-0c74194ba257-000000@email.amazonses.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 03:16:44PM +0000, Christopher Lameter wrote:
> On Mon, 25 Feb 2019, Dennis Zhou wrote:
> 
> > > @@ -27,7 +27,7 @@
> > >   *   chunk size is not aligned.  percpu-km code will whine about it.
> > >   */
> > >
> > > -#if defined(CONFIG_SMP) && defined(CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK)
> > > +#if defined(CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK)
> > >  #error "contiguous percpu allocation is incompatible with paged first chunk"
> > >  #endif
> > >
> > > --
> > > 2.16.4
> > >
> >
> > Hi,
> >
> > I think keeping CONFIG_SMP makes this easier to remember dependencies
> > rather than having to dig into the config. So this is a NACK from me.
> 
> But it simplifies the code and makes it easier to read.
> 
> 

I think the check isn't quite right after looking at it a little longer.
Looking at x86, I believe you can compile it with !SMP and
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK will still be set. This should
still work because x86 has an MMU.

I think more correctly it would be something like below, but I don't
have the time to fully verify it right now.

Thanks,
Dennis

---
diff --git a/mm/percpu-km.c b/mm/percpu-km.c
index 0f643dc2dc65..69ccad7d9807 100644
--- a/mm/percpu-km.c
+++ b/mm/percpu-km.c
@@ -27,7 +27,7 @@
  *   chunk size is not aligned.  percpu-km code will whine about it.
  */
 
-#if defined(CONFIG_SMP) && defined(CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK)
+#if !defined(CONFIG_MMU) && defined(CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK)
 #error "contiguous percpu allocation is incompatible with paged first chunk"
 #endif
 

