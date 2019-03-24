Return-Path: <SRS0=4n/l=R3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AD8FC4360F
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 14:44:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F36D5222EA
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 14:44:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F36D5222EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hallyn.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F2C46B0003; Sun, 24 Mar 2019 10:44:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A1DB6B0006; Sun, 24 Mar 2019 10:44:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 244806B0007; Sun, 24 Mar 2019 10:44:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA7916B0003
	for <linux-mm@kvack.org>; Sun, 24 Mar 2019 10:44:06 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id t18so2137315wmj.3
        for <linux-mm@kvack.org>; Sun, 24 Mar 2019 07:44:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0yIfHbHAo2NF7XwDo1oKLIsjcSMuaDKl8bKZdw8OthQ=;
        b=G5NYwaRFtqPZR+XJzA0pfJjhGUqVp5Gt5TsfUt4FaSdxrxSSQPaRq0oEdL5pTimDv8
         xC3x6XkzWMuzp9uT7oyHBK0kw2ooB6MRmfSaoYOZDeiqVUMgvBoaatjryZSObyMzEETb
         pLB1toa9JImMoj3x2bmu8nnZQoZSWOVl9de+c3P/pBemjj+lSsQesrgEjzsezwBopmaR
         /J7A9jjJHup6F+bLBg2ZmC5DL7mQuVn/e+MSZOSLuMqfW/SYwYZNnT7YhKG4M4uxCjQC
         LbcI9to4xEOK0vutM7x+BSa+57/rismnMKlht3SVbTUJLRT5IgNlORiBqkCGX6Hy6cOo
         qXtQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of serge@mail.hallyn.com designates 178.63.66.53 as permitted sender) smtp.mailfrom=serge@mail.hallyn.com
X-Gm-Message-State: APjAAAVF5xGUD8BntSAaR42b06STHem5muzjzSSelhV45ig4Ox4aI9G0
	pz8ckX9HawQ9lsN65GHifYUAL/ax7NGwbiWf8bchihXTH8zXfA0oZ1AMR4NBrgtQNgEXcmn0184
	OpFUTWhTOGLfr8boyUIynkz60mmNE2P7rC4JhKeinV1+XJMzCTsdlmXbj+u24Ms0dBg==
X-Received: by 2002:adf:b68d:: with SMTP id j13mr8079838wre.50.1553438646237;
        Sun, 24 Mar 2019 07:44:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsis7g4813nd5xqJqCbQd3hbqlplCzEevoVK8FCFuoc5C8cidSeAZw648Oi7SsDyRsfFSM
X-Received: by 2002:adf:b68d:: with SMTP id j13mr8079806wre.50.1553438645348;
        Sun, 24 Mar 2019 07:44:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553438645; cv=none;
        d=google.com; s=arc-20160816;
        b=O8hhqOgzkRg7ZJAL0HLCe+8bdFtcigd/8JjDmNkarxS8ZTq500CSsTG/vijKTg9dvP
         xkF5JSXwuZdKifLraUsT/F26QHfS79U2+m9m/UflK2naVTP7CWrR6GJ2kgnT/WaKpdCV
         ncTf2ZMo00Ki7iFl6OznjSBeu2o0JbRP3GrUnlySO54BRqoHc2HgQdvVU2hEVarPCD9U
         qaEWszh0a/K1rYOYIaVo+sjVgXcCzvTSP6jhfHAb3NpREpWTsEXXBC0937ZLsYWRbtWL
         ADfw79UqSUAf/g8ryqsaI8jNRchCM5LkJtakSt+ru3MVaDi9y8JwjwiyEPu2oWZ47fhv
         CIzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0yIfHbHAo2NF7XwDo1oKLIsjcSMuaDKl8bKZdw8OthQ=;
        b=F8Y9wUba4XczF+valAwQEdtCjTP352Ff/oJ2/64+5CADnpJdPv48qkad7RZEfRsjpO
         h1SE7aJoHFy8q7WC2T9F+GZnwjBjVyBckHadMFm31/7JEpxS9wOTr24PneeICGBIqcUQ
         L8vKlZeY04LngsHo35TtxLu2hwdy47vACmXOEOarIIkPlBx5Pc+U7CTTttPk9UTcFUWp
         in/klpFNOfh5TQoRy6FcJ7pFQF5S43DElGo2aDB/+qxjKSULGwPLlhwe/td8/N+Lq2KA
         7lhWZ2RbvJJNtLexQlpPsDfV+HvBA9FQyDt+U9dKMZP191TNX9otMwx+QxKgjURcfeyc
         hM3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of serge@mail.hallyn.com designates 178.63.66.53 as permitted sender) smtp.mailfrom=serge@mail.hallyn.com
Received: from mail.hallyn.com (mail.hallyn.com. [178.63.66.53])
        by mx.google.com with ESMTPS id y4si6463115wrt.288.2019.03.24.07.44.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 24 Mar 2019 07:44:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of serge@mail.hallyn.com designates 178.63.66.53 as permitted sender) client-ip=178.63.66.53;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of serge@mail.hallyn.com designates 178.63.66.53 as permitted sender) smtp.mailfrom=serge@mail.hallyn.com
Received: by mail.hallyn.com (Postfix, from userid 1001)
	id C7E72E; Sun, 24 Mar 2019 09:44:04 -0500 (CDT)
Date: Sun, 24 Mar 2019 09:44:04 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Daniel Colascione <dancol@google.com>
Cc: Christian Brauner <christian@brauner.io>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Sultan Alsawaf <sultan@kerneltoast.com>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	linux-mm <linux-mm@kvack.org>,
	kernel-team <kernel-team@android.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Kees Cook <keescook@chromium.org>
Subject: Re: pidfd design
Message-ID: <20190324144404.GA32603@mail.hallyn.com>
References: <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <CAKOZuetJzg_EiyuK7Pa13X3LKuBbreg7zJ5g4uQv_uV4wpmZjg@mail.gmail.com>
 <20190320035953.mnhax3vd47ya4zzm@brauner.io>
 <CAKOZuet3-VhmC3oHtEbPPvdiar_k_QXTf0TkgmH9LiwmW-_oNA@mail.gmail.com>
 <4A06C5BB-9171-4E70-BE31-9574B4083A9F@joelfernandes.org>
 <20190320182649.spryp5uaeiaxijum@brauner.io>
 <CAKOZuevHbQtrq+Nb-jw1L7O72BmAzcXmbUnfnseeXZjX4PE4tg@mail.gmail.com>
 <20190320185156.7bq775vvtsxqlzfn@brauner.io>
 <CAKOZuetKkPaAZvRZyG3V6RMAgOJx08dH4K4ABqLnAf53WRUHTg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuetKkPaAZvRZyG3V6RMAgOJx08dH4K4ABqLnAf53WRUHTg@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 12:29:31PM -0700, Daniel Colascione wrote:
> On Wed, Mar 20, 2019 at 11:52 AM Christian Brauner <christian@brauner.io> wrote:
> > I really want to see Joel's pidfd_wait() patchset and have more people
> > review the actual code.
> 
> Sure. But it's also unpleasant to have people write code and then have
> to throw it away due to guessing incorrectly about unclear
> requirements.

No, it is not.  It is not unpleasant.  And it is useful.  It is the best way to
identify and resolve those incorrect guesses and unclear requirements.

