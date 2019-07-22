Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27AA8C76194
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 11:51:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D364D2184E
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 11:51:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D364D2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 696DD6B0005; Mon, 22 Jul 2019 07:51:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 648FB6B0006; Mon, 22 Jul 2019 07:51:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 510738E0001; Mon, 22 Jul 2019 07:51:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 309876B0005
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 07:51:58 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id i73so29522029ywa.18
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 04:51:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=Y5YhRENCsAuv7KQ1ejes6bqF9KsDFuISWTCi48JD5Y8=;
        b=jCwGVd66jlIgAjPJ32DZADy5ho99IAO2oVdaeuk+61DZFeLMQYS0NSf6EjEw7/mqs9
         E+c/PKbYtbpKRn1j2+a2769pM+ByAsk7uRGpVJi7eEgntSZpwISc4icIOgsZ5KZNkZOt
         QbRhcKQvovLr4JzNMyOpIaEPdjMuj8XCNGiYndYsmRHDUCWN/bljHTryOjaCF4F8vXTR
         boG3CFF3z3tdnK/V7G3do9wuHPkCNR7J+hqN0UrT5IewAOM4Xm9cG0EiZYHfRf5rUlET
         HHdYUoJxS4A91yKj/98kdm2B0ERtg4hMkqG2woP2SQ0xvvrydC8rxxYg3oC5F1yOn0Pf
         Zf9g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXRetkrOlJefy+tTcNO4UXvCt1+ay9qeffUAC2t+RvyyOfZ15Ct
	4KrIRFYpUjEqD8SapU6pTzBK1VgwD8BjtY9ihfwzuP7Hd+yC7dCJbGej/gSBgVu4HjDXILCCtDI
	5EwvxB1SXHO2JGvpgeAnRLCfQkdoDsPkv3Q3qciHHGdsOqQKwJ6Ekm1THyzIkOr8=
X-Received: by 2002:a25:a28e:: with SMTP id c14mr36124039ybi.141.1563796317948;
        Mon, 22 Jul 2019 04:51:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKhLd/gidliYPGkgH5KtEzBgjvlg0IinWZaX70/ll4sB8o8sCqtoGv4pLAKoa63a+9WLEs
X-Received: by 2002:a25:a28e:: with SMTP id c14mr36124008ybi.141.1563796317025;
        Mon, 22 Jul 2019 04:51:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563796317; cv=none;
        d=google.com; s=arc-20160816;
        b=Yu15qxyGhKzFHsKIuaqHC7CsiBXUn4aON9Ywu7eYXQa/FYxFG+XnbJKo9UzfpDsS2c
         DS/6h3PVV1RZn0zuzkFikmI3IqodkPeyy8JdkZuIwETLBxJslnb/LWK9RHATbhVE9M0R
         2MVBJ1QHf4pQXj+b8HYbEWlkldRvEDNaXrdZA4AP1HTcFqFTfcLdHk2X27fiipLNntQu
         J8JwuB+seqYOY2J9SZj/Hc/P95MERGERy0FZI9ayvBm8EUSHunW++8QDSkiSwgZAsyX7
         m94IulHyd2Xm4woFXIQSAJV+q+3Wy7+Ckr68EzH1PRpa1HvgG2J5dyCcc4V9cSsx9sPW
         uZKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=Y5YhRENCsAuv7KQ1ejes6bqF9KsDFuISWTCi48JD5Y8=;
        b=uKDnjeEy7fevLPqETEvZ/LdqX2FlOh9u+B1s2ZQ4kGTZf6Lv/C9a0KGLsMMgFzBRH3
         TtLFuRJeL+Cm5ymwz66RhQMkybiX/EcgXqH5c9VsvVhBWGq25p8yPTzrT/JQ7PyBHluo
         Itovpk6qJ9MCPt/0uAn71Y8pUyHDm+guKdboQm5lJNciy0PlKbg2I9n/DXdGW5DViHrr
         a5w20+Q1vL6KhQGlt2GA6ALor8w4fmF/mHlc1UOksilXZn7JBUV9B0kbhrDx7aJKjMio
         ngKXzYa/JbRJF9NIlMnKq213hA1LIshzaP4i4sEpGKbMOFn97jwJx21GTSdsd7TAwSq1
         fxBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b137si15730261ywh.153.2019.07.22.04.51.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 04:51:56 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6MBmKoQ103565
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 07:51:56 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2twc9d93yg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 07:51:56 -0400
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 22 Jul 2019 12:51:55 +0100
Received: from b01cxnp22034.gho.pok.ibm.com (9.57.198.24)
	by e14.ny.us.ibm.com (146.89.104.201) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 22 Jul 2019 12:51:49 +0100
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6MBpmq544761478
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 22 Jul 2019 11:51:48 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3D4A8B206A;
	Mon, 22 Jul 2019 11:51:48 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DFD7EB2066;
	Mon, 22 Jul 2019 11:51:47 +0000 (GMT)
Received: from paulmck-ThinkPad-W541 (unknown [9.85.189.166])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Mon, 22 Jul 2019 11:51:47 +0000 (GMT)
Received: by paulmck-ThinkPad-W541 (Postfix, from userid 1000)
	id 2B8E916C2E45; Mon, 22 Jul 2019 04:51:49 -0700 (PDT)
Date: Mon, 22 Jul 2019 04:51:49 -0700
From: "Paul E. McKenney" <paulmck@linux.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, aarcange@redhat.com,
        akpm@linux-foundation.org, christian@brauner.io, davem@davemloft.net,
        ebiederm@xmission.com, elena.reshetova@intel.com, guro@fb.com,
        hch@infradead.org, james.bottomley@hansenpartnership.com,
        jasowang@redhat.com, jglisse@redhat.com, keescook@chromium.org,
        ldv@altlinux.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-parisc@vger.kernel.org, luto@amacapital.net, mhocko@suse.com,
        mingo@kernel.org, namit@vmware.com, peterz@infradead.org,
        syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
        wad@chromium.org
Subject: Re: RFC: call_rcu_outstanding (was Re: WARNING in __mmdrop)
Reply-To: paulmck@linux.ibm.com
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <20190721081933-mutt-send-email-mst@kernel.org>
 <20190721131725.GR14271@linux.ibm.com>
 <20190721210837.GC363@bombadil.infradead.org>
 <20190721233113.GV14271@linux.ibm.com>
 <20190722035042-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722035042-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-TM-AS-GCONF: 00
x-cbid: 19072211-0052-0000-0000-000003E3F8C7
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011474; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000287; SDB=6.01235799; UDB=6.00651288; IPR=6.01017148;
 MB=3.00027836; MTD=3.00000008; XFM=3.00000015; UTC=2019-07-22 11:51:55
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19072211-0053-0000-0000-000061CB4F70
Message-Id: <20190722115149.GY14271@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-22_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=669 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907220141
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 03:52:05AM -0400, Michael S. Tsirkin wrote:
> On Sun, Jul 21, 2019 at 04:31:13PM -0700, Paul E. McKenney wrote:
> > On Sun, Jul 21, 2019 at 02:08:37PM -0700, Matthew Wilcox wrote:
> > > On Sun, Jul 21, 2019 at 06:17:25AM -0700, Paul E. McKenney wrote:
> > > > Also, the overhead is important.  For example, as far as I know,
> > > > current RCU gracefully handles close(open(...)) in a tight userspace
> > > > loop.  But there might be trouble due to tight userspace loops around
> > > > lighter-weight operations.
> > > 
> > > I thought you believed that RCU was antifragile, in that it would scale
> > > better as it was used more heavily?
> > 
> > You are referring to this?  https://paulmck.livejournal.com/47933.html
> > 
> > If so, the last few paragraphs might be worth re-reading.   ;-)
> > 
> > And in this case, the heuristics RCU uses to decide when to schedule
> > invocation of the callbacks needs some help.  One component of that help
> > is a time-based limit to the number of consecutive callback invocations
> > (see my crude prototype and Eric Dumazet's more polished patch).  Another
> > component is an overload warning.
> > 
> > Why would an overload warning be needed if RCU's callback-invocation
> > scheduling heurisitics were upgraded?  Because someone could boot a
> > 100-CPU system with the rcu_nocbs=0-99, bind all of the resulting
> > rcuo kthreads to (say) CPU 0, and then run a callback-heavy workload
> > on all of the CPUs.  Given the constraints, CPU 0 cannot keep up.
> > 
> > So warnings are required as well.
> > 
> > > Would it make sense to have call_rcu() check to see if there are many
> > > outstanding requests on this CPU and if so process them before returning?
> > > That would ensure that frequent callers usually ended up doing their
> > > own processing.
> > 
> > Unfortunately, no.  Here is a code fragment illustrating why:
> > 
> > 	void my_cb(struct rcu_head *rhp)
> > 	{
> > 		unsigned long flags;
> > 
> > 		spin_lock_irqsave(&my_lock, flags);
> > 		handle_cb(rhp);
> > 		spin_unlock_irqrestore(&my_lock, flags);
> > 	}
> > 
> > 	. . .
> > 
> > 	spin_lock_irqsave(&my_lock, flags);
> > 	p = look_something_up();
> > 	remove_that_something(p);
> > 	call_rcu(p, my_cb);
> > 	spin_unlock_irqrestore(&my_lock, flags);
> > 
> > Invoking the extra callbacks directly from call_rcu() would thus result
> > in self-deadlock.  Documentation/RCU/UP.txt contains a few more examples
> > along these lines.
> 
> We could add an option that simply fails if overloaded, right?
> Have caller recover...

For example, return EBUSY from your ioctl?  That should work.  You could
also sleep for a jiffy or two to let things catch up in this BUSY (or
similar) case.  Or try three times, waiting a jiffy between each try,
and return EBUSY if all three tries failed.

Or just keep it simple and return EBUSY on the first try.  ;-)

All of this assumes that this ioctl is the cause of the overload, which
during early boot seems to me to be a safe assumption.

							Thanx, Paul

