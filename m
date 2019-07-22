Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD669C76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:14:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 717BA204FD
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:14:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="XQ0f5nx8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 717BA204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C19E56B0003; Mon, 22 Jul 2019 11:14:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCB9D6B0005; Mon, 22 Jul 2019 11:14:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABA2C8E0001; Mon, 22 Jul 2019 11:14:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 766126B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:14:44 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i27so24042433pfk.12
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:14:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=i8M6AK4de9Ik8pIGK7ZSAo/fkLcx89Rz2FU4ueU7AtI=;
        b=nftyXU2vcYxmZSCo18d9Wu5cvYFPiOIlAbLGjpaREm6DwHPPR+y7vVupdzH7m5G+G+
         N06Z0lsfzXW2RVuYQkT/qM6ZI/pP8BO2QN41judhH+48zzxiXsfFfXReLdjAwsyLDBgL
         quPmq1YKMb/jwc9ZyhQaf6hA34pydR+sZwev27SNr6HmOgqE4W4TdEGiqxs5PILWkEpp
         N4pibn+6F1EG4hrcSXxiDyc2JG9CH3j9fmS9WTiDGtEqKygbpmhyevZZa+JI8BnvBOzA
         lw4qATevaMMkS0ekhEfMqGeAxBLXl07NzCKClaT9yIBc3frGxMqgPQp19tytW4z9zScy
         u0Kw==
X-Gm-Message-State: APjAAAXBhyPFLhoMLg8T2zLeFBMN6XOdfv7jw+GQOKSi0vjc3pqavBPI
	Rl6mdkOVOOppAIBcb/G5AOxQSiwrHXAsHp2QamWsQxV9geWuxx2AQjSYGdXSbpw5QV+gDbGg4L5
	0qTAB3nSQgms9o8urAeV3w/u8x/tLurfYlBGowGBfqEzi6i7L37bzbCPO207e1HmL2Q==
X-Received: by 2002:a63:b64:: with SMTP id a36mr62241920pgl.215.1563808483897;
        Mon, 22 Jul 2019 08:14:43 -0700 (PDT)
X-Received: by 2002:a63:b64:: with SMTP id a36mr62241822pgl.215.1563808482698;
        Mon, 22 Jul 2019 08:14:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563808482; cv=none;
        d=google.com; s=arc-20160816;
        b=PTYXt1VvILooXrMU9tb9qMfYA81EChQAezhTZGgrFLT/3A+YwcnZhDViGUx8lqbT7c
         SsBw6HeUTV4ovzYx+GWXFc68xrX7X/+BE9j+94qQx79YIpVHyAUm4aa71K9o433wgMl3
         XQLl3lDN1PoEP0y85Qp88YNHBnEC/QODWJllVJe/62C20z0jGT6vU15ewD4RIkE+xL6q
         AWIZ7jTvZqi7U97AVv3LjZRfK/h4+d5IyDRQzfa2dp7qPtnxz6iJp7nq+rDQ+i3rFROB
         HY2WrwA+FR5kUK3MAv98R2CgTlKwRDBWwwS1SX7xZX9wliZ9Ap10hWQ+IjMJghZ8b9La
         OEDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=i8M6AK4de9Ik8pIGK7ZSAo/fkLcx89Rz2FU4ueU7AtI=;
        b=fdlmnQZJ8l8SXJQue8ONDksUH7Au+xN4XCMMUJWXgShV2rCXcG7pvOPIQufHKi6UwU
         koe1CFimMrW0eAhqz6pT2YaAj0mlQH16Yp0CxZf7lJ1ntggOL0DnZMC3GI+beH/a/1nx
         Oe471t2QVrwvNAlMNUvFjGp2fePQF6U9ZtpjQmjJqj5RnUfkivWjgEqMT71QgmYht2zf
         MEAdif3HfHuQ2gfRS5wRJdt2zPW8Szg1Fs9kPXXTxvocwBLTqYtZtw81xMd7zHs1wUaX
         8QBMBLFFxwUrINx/xyqJJNyVFCtPPD86AgLb+klCbEcKO8PvbCDdx4mMOy/qpg/svc/8
         ytug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=XQ0f5nx8;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x24sor21004247pgk.36.2019.07.22.08.14.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 08:14:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=XQ0f5nx8;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=i8M6AK4de9Ik8pIGK7ZSAo/fkLcx89Rz2FU4ueU7AtI=;
        b=XQ0f5nx8fa3pklvdGG2u9IOZZJTUyDUTYVVk+sNJ3SCJPR77BhV8NbHcipLbVy1xvT
         Slg0Se3QHTC0ZyO53T8oEMnYmpMj/IpwJ3J26/3ycCvlPIjGxwvchFbXcMJqk0o/mpqq
         1Yt0CuEo1ILTMuVgHTe5nTzixjn08mjGXwYpQ=
X-Google-Smtp-Source: APXvYqydSiyMRzj6QXFVzUWNzUL0LUUvnGotJgLD9n9VUjcgfggnl8W+/75TLlsXhUbwOLV6q6l9PQ==
X-Received: by 2002:a63:1310:: with SMTP id i16mr71092692pgl.187.1563808481910;
        Mon, 22 Jul 2019 08:14:41 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id h1sm51944925pfg.55.2019.07.22.08.14.40
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 08:14:40 -0700 (PDT)
Date: Mon, 22 Jul 2019 11:14:39 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: "Paul E. McKenney" <paulmck@linux.ibm.com>
Cc: Matthew Wilcox <willy@infradead.org>,
	"Michael S. Tsirkin" <mst@redhat.com>, aarcange@redhat.com,
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
Message-ID: <20190722151439.GA247639@google.com>
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <20190721081933-mutt-send-email-mst@kernel.org>
 <20190721131725.GR14271@linux.ibm.com>
 <20190721210837.GC363@bombadil.infradead.org>
 <20190721233113.GV14271@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190721233113.GV14271@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[snip]
> > Would it make sense to have call_rcu() check to see if there are many
> > outstanding requests on this CPU and if so process them before returning?
> > That would ensure that frequent callers usually ended up doing their
> > own processing.

Other than what Paul already mentioned about deadlocks, I am not sure if this
would even work for all cases since call_rcu() has to wait for a grace
period.

So, if the number of outstanding requests are higher than a certain amount,
then you *still* have to wait for some RCU configurations for the grace
period duration and cannot just execute the callback in-line. Did I miss
something?

Can waiting in-line for a grace period duration be tolerated in the vhost case?

thanks,

 - Joel

