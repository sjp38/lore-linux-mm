Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F2C9C76196
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 07:52:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBC7B21BE6
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 07:52:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBC7B21BE6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 834266B0003; Mon, 22 Jul 2019 03:52:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BF6D6B0006; Mon, 22 Jul 2019 03:52:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 684A08E0003; Mon, 22 Jul 2019 03:52:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 43F856B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 03:52:17 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id g30so34816528qtm.17
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 00:52:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=wYyXdvJ27O2FTyENDZboMSuBZ4fFOoN7k0htsw1kQ74=;
        b=ordC9Df1GZgg2K5eaUcjJNSew4U16/HfP59LHSuOn71pd0XdUPZHej/jeyeGtbRzVf
         wLAb9xTOMVO+4Z92GhZINiA+NffxsQUs5CfWutV0x3nCE63iIWfJiWe1LT+XKVOqLqma
         iAxpF9Ilqi7sVJwhDGuLzgp1UrZOdK2KicQ5+IloYNiKcCjZWZCqcg2ZLOwfJrbWgkea
         v+iRjqd6RoJpNOuJvvN8maLGVeTDcCQFyuUFA5Q+So2K4N0zf6ONcUiZE6BHaMGU4/NE
         x9AeFcMqDW1CRSoOLZjAuHa5X26M6FpZQOpNAdMEnI52rV60B/DNGOBtJhqtMqtm02wj
         ixwQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWQdwLC6qKFNWAo90CmYP9gx1ZsRMPKjmizgKRB6kCKI5jNV4QI
	GO/+HmVTguP9/QNxGPQK8oYJ+H8e4A2PovZKiTPCiuqdBYN/mjkT2WFJ5AyQ734VaVyLrCe1iEy
	xyGRS+JWx9tpmwOahf7O7wStdRZIEKRiKjlCOMGvTV/9yNQ1ijAroJgyGM02GSOlDYw==
X-Received: by 2002:a37:ac1a:: with SMTP id e26mr46932932qkm.231.1563781937006;
        Mon, 22 Jul 2019 00:52:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxT5GjewzEWseFF+KZ0hXC9H+Fw4dhqApSTEOHPrbTt2i+EAFJlWb3yJkUNuMaGvTdhwXH0
X-Received: by 2002:a37:ac1a:: with SMTP id e26mr46932906qkm.231.1563781936355;
        Mon, 22 Jul 2019 00:52:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563781936; cv=none;
        d=google.com; s=arc-20160816;
        b=IUSHD/HMUjfGkgEkmkFH7cU4/xXzp1sMbEs3o7wmmTTmAxU0sMg29uPSEqWtbOpjsj
         Dcj4AQe4KHQzWWN6lO4gb6PXFKizt5Ou4ClyukPTvwo/KarOKAYrRY+yA57z06ruAvkB
         ryokjgpvAkpbMQwSKPVkq3T7bEy89CF6XRbVZwiWnR00lNfcNUTIQi+ZpCPW5NjL7a6D
         Yv9uo/lbsgS2ibH83iSw3Kx+P1m+K98If3CwTPXBl4S3M+gwbCPkgQqwbRqNYp4Xn7RT
         pi2zrMcloFqJVa0epXa4WmosWYJlK9QsHCYJvr1zdXilapZzKS/x1g3khaPrGQ/pj9Bp
         IPWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=wYyXdvJ27O2FTyENDZboMSuBZ4fFOoN7k0htsw1kQ74=;
        b=BC2oI1fCETrp1jaBc79uVBR5DY1ZmdxYHfd/G1gFF/SKZ+SwT6EKV/J9s/J3CJvH9r
         rifmRSWWo9/Da10efCAc89GoSFU9RhAXPbyx0sL+dv1SQAmzYVGdVNlmmYh89aTbjgiN
         5D4vD99ezOoX0h67Y3bUpGYRawGMJW00b9UD/xMaZUg5IWIUbbmqtpzG20LdxnEAJu8E
         MpPKlpxV46dSnALw9hnrNqUfrweqqN2vBO3dddKgmrn63NHG4FTWpbZ3HzIjdfzENzHX
         GYX0qbeDHFN7cjgBszpJBeA2ujKwsAWXf7Syc1+R27KIfFY8Ywj3g+drNkdjXePvIXeG
         0XyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y7si24804534qvp.116.2019.07.22.00.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 00:52:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1176F86668;
	Mon, 22 Jul 2019 07:52:15 +0000 (UTC)
Received: from redhat.com (ovpn-120-233.rdu2.redhat.com [10.10.120.233])
	by smtp.corp.redhat.com (Postfix) with SMTP id 5B9085C221;
	Mon, 22 Jul 2019 07:52:06 +0000 (UTC)
Date: Mon, 22 Jul 2019 03:52:05 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: "Paul E. McKenney" <paulmck@linux.ibm.com>
Cc: Matthew Wilcox <willy@infradead.org>, aarcange@redhat.com,
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
Message-ID: <20190722035042-mutt-send-email-mst@kernel.org>
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
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Mon, 22 Jul 2019 07:52:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2019 at 04:31:13PM -0700, Paul E. McKenney wrote:
> On Sun, Jul 21, 2019 at 02:08:37PM -0700, Matthew Wilcox wrote:
> > On Sun, Jul 21, 2019 at 06:17:25AM -0700, Paul E. McKenney wrote:
> > > Also, the overhead is important.  For example, as far as I know,
> > > current RCU gracefully handles close(open(...)) in a tight userspace
> > > loop.  But there might be trouble due to tight userspace loops around
> > > lighter-weight operations.
> > 
> > I thought you believed that RCU was antifragile, in that it would scale
> > better as it was used more heavily?
> 
> You are referring to this?  https://paulmck.livejournal.com/47933.html
> 
> If so, the last few paragraphs might be worth re-reading.   ;-)
> 
> And in this case, the heuristics RCU uses to decide when to schedule
> invocation of the callbacks needs some help.  One component of that help
> is a time-based limit to the number of consecutive callback invocations
> (see my crude prototype and Eric Dumazet's more polished patch).  Another
> component is an overload warning.
> 
> Why would an overload warning be needed if RCU's callback-invocation
> scheduling heurisitics were upgraded?  Because someone could boot a
> 100-CPU system with the rcu_nocbs=0-99, bind all of the resulting
> rcuo kthreads to (say) CPU 0, and then run a callback-heavy workload
> on all of the CPUs.  Given the constraints, CPU 0 cannot keep up.
> 
> So warnings are required as well.
> 
> > Would it make sense to have call_rcu() check to see if there are many
> > outstanding requests on this CPU and if so process them before returning?
> > That would ensure that frequent callers usually ended up doing their
> > own processing.
> 
> Unfortunately, no.  Here is a code fragment illustrating why:
> 
> 	void my_cb(struct rcu_head *rhp)
> 	{
> 		unsigned long flags;
> 
> 		spin_lock_irqsave(&my_lock, flags);
> 		handle_cb(rhp);
> 		spin_unlock_irqrestore(&my_lock, flags);
> 	}
> 
> 	. . .
> 
> 	spin_lock_irqsave(&my_lock, flags);
> 	p = look_something_up();
> 	remove_that_something(p);
> 	call_rcu(p, my_cb);
> 	spin_unlock_irqrestore(&my_lock, flags);
> 
> Invoking the extra callbacks directly from call_rcu() would thus result
> in self-deadlock.  Documentation/RCU/UP.txt contains a few more examples
> along these lines.

We could add an option that simply fails if overloaded, right?
Have caller recover...

-- 
MST

