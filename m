Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29E0FC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 18:49:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE01F21871
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 18:49:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="XlCmr86N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE01F21871
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 948716B02A1; Fri, 15 Mar 2019 14:49:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F7C86B02A2; Fri, 15 Mar 2019 14:49:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E6816B02A3; Fri, 15 Mar 2019 14:49:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 53D8C6B02A1
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 14:49:07 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id d24so9565319qtj.19
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 11:49:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=jDVu9oumcNkqVWq1A9ByqO3eErH+1lF+kli+4UwjDSo=;
        b=jMcWcRK1Lb0WhCDNzmBL9BBC/pHEnOm1pdZXmNom12RCJMqZRUcIudF+J9Tf5bS+2u
         klsmgw0WeQAsK+RRNd77LcqP54fHfaXsFF3LpvGF3481mJg8UKlhUspmNyU5Sj0Yq0HA
         jmzGIgY+1Qxvv5JbWGkUCZy7w91J9FG0ndYYr2DeWZNDR+U8PsWM4pYGchyFYKrOdlUV
         q87giluJDq0zdz4BdH0vnrjrCn8UiNsYxNVVj7aNeDA41dm7s8U1sTipWLoSKa403YJC
         jn/oSlTkG1ncJuMW0FtK39myGMznt4ejSicjTu8v7nS0yqpqdZiafwFxpWhplmJesOwa
         eqfw==
X-Gm-Message-State: APjAAAVgAxDHBNN+d+Gu3ius5AQLcNrQcquzi5TJNb0ch+RkhV1DvdZz
	Q12wj+MZ5uTkYHP6J6DyrNyTcrlDHHh8mexYvboHeXK0vvVT5OaS+MBe8HzqKOUma9qrD+7Niis
	vy5h1w/NkMrSoIxkzGsPW8a6FaBKQ2Hi9kWjvpzICy4TNw4yP9aDevaQ+P8rs4MZWEw==
X-Received: by 2002:a37:47cb:: with SMTP id u194mr3938023qka.296.1552675746625;
        Fri, 15 Mar 2019 11:49:06 -0700 (PDT)
X-Received: by 2002:a37:47cb:: with SMTP id u194mr3937976qka.296.1552675745741;
        Fri, 15 Mar 2019 11:49:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552675745; cv=none;
        d=google.com; s=arc-20160816;
        b=xNb31GwdJrghDAttB/K+mnzJJt9dFxWBN3xrdmwVQI0hDKV12e1ZIh4Y01OxlrQQCY
         7hZOo+uAlGg8vLlRO956QVdXq9/LRNZKfD3/iucNwc4H55OwNhiU0bn1I6jpaMfnSyDn
         1/RF8T8kpqPwSUeZboW6atQ4uxIceOe8ZgpHO73f16WlEJMXkrCxqVJjuHur/KGKuWBg
         GwN1zDAS2fdYbfY/t1s5EkANDN9UyyS/mg+liL6eQU5LhjEw7fzfwTHtwchxYrn4cO7/
         qUAAUHzJgtLH0RnhEuoqc39VTCBhzAgsx0ze9uWhpDZyFetcRTs21jARBGNMN/dWXFCs
         QDxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=jDVu9oumcNkqVWq1A9ByqO3eErH+1lF+kli+4UwjDSo=;
        b=y31l48ODD8B7oN78WY48vK6cGkiGNNmHIgPz2kNkbiuTIM7vgsOBxbI4mGgdnSNojy
         4GP6K4tC7Sw5Px2KNEDZsLtCAcxTwNTQCMrYnZdRgB2ko8hkBqyPh3upsYBh/19lTT+f
         iVGFCwLTL02Rj9KnxpY3puso8pF3rI6z6ZRQ7EhGIcsHDwadKbUlxtoodQjNY0cv7T1m
         7eVyoTa3Nb+UNzfxgecfFuTrqRFa4nJ5Bg4dm+ew2yjwcH2MuNATTBr2b0Qv9NJpDyeU
         nlYVuxSwcbamW0TruioZxirjeXKSyZaq4GKSGVG+Q/FsOfLAOvrUC/j6VWCFwTE++5Ex
         LzQg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=XlCmr86N;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p23sor3502704qtn.56.2019.03.15.11.49.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 11:49:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=XlCmr86N;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=jDVu9oumcNkqVWq1A9ByqO3eErH+1lF+kli+4UwjDSo=;
        b=XlCmr86Nfgg3xBxju2EZKTlTIuahwPKKbKnb6AAlhmp/tbiXOHmzB9Z4TTY65xaPhY
         h4du8n5E8MqaLaMPiBzkN0MAjbdzjR75E/AcT2yQNsgUl/sytZ2UHw3nW5f5SaJzdt7G
         qzWXFPPAMKCh8WrfHRT1c/0etmimiPLKZ6KAE=
X-Google-Smtp-Source: APXvYqw8pCjTHPS+C/nJz1ilQ/4K2gffZ1/50M17YBUUilptOjlnj0xzZ/lMuV0kS8T6iuWCBA4H8g==
X-Received: by 2002:ac8:3042:: with SMTP id g2mr4025863qte.1.1552675745275;
        Fri, 15 Mar 2019 11:49:05 -0700 (PDT)
Received: from localhost ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id m88sm1384596qte.68.2019.03.15.11.49.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Mar 2019 11:49:04 -0700 (PDT)
Date: Fri, 15 Mar 2019 14:49:03 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Christian Brauner <christian@brauner.io>
Cc: Daniel Colascione <dancol@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Sultan Alsawaf <sultan@kerneltoast.com>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	linux-mm <linux-mm@kvack.org>,
	kernel-team <kernel-team@android.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190315184903.GB248160@google.com>
References: <20190312080532.GE5721@dhcp22.suse.cz>
 <20190312163741.GA2762@sultan-box.localdomain>
 <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
 <CAEXW_YQMnbN+e-janGbZc5MH6MwdUdXNfonpLUu5O2nsSkJyeg@mail.gmail.com>
 <20190314204911.GA875@sultan-box.localdomain>
 <20190314231641.5a37932b@oasis.local.home>
 <CAKOZuetZHJzmQy3n001x4+rmWoWHEgUv2Zvow9W5+xvukxp1JQ@mail.gmail.com>
 <20190315180306.sq3z645p3hygrmt2@brauner.io>
 <20190315181324.GA248160@google.com>
 <20190315182426.sujcqbzhzw4llmsa@brauner.io>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190315182426.sujcqbzhzw4llmsa@brauner.io>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 15, 2019 at 07:24:28PM +0100, Christian Brauner wrote:
[..]
> > why do we want to add a new syscall (pidfd_wait) though? Why not just use
> > standard poll/epoll interface on the proc fd like Daniel was suggesting.
> > AFAIK, once the proc file is opened, the struct pid is essentially pinned
> > even though the proc number may be reused. Then the caller can just poll.
> > We can add a waitqueue to struct pid, and wake up any waiters on process
> > death (A quick look shows task_struct can be mapped to its struct pid) and
> > also possibly optimize it using Steve's TIF flag idea. No new syscall is
> > needed then, let me know if I missed something?
> 
> Huh, I thought that Daniel was against the poll/epoll solution?

Hmm, going through earlier threads, I believe so now. Here was Daniel's
reasoning about avoiding a notification about process death through proc
directory fd: http://lkml.iu.edu/hypermail/linux/kernel/1811.0/00232.html

May be a dedicated syscall for this would be cleaner after all.

> I have no clear opinion on what is better at the moment since I have
> been mostly concerned with getting pidfd_send_signal() into shape and
> was reluctant to put more ideas/work into this if it gets shutdown.
> Once we have pidfd_send_signal() the wait discussion makes sense.

Ok. It looks like that is almost in though (fingers crossed :)).

thanks,

 - Joel

