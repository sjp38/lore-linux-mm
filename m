Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96024C76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:52:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C53F218EA
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:52:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C53F218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9C938E0018; Mon, 22 Jul 2019 11:52:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4A458E000E; Mon, 22 Jul 2019 11:52:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B11B18E0018; Mon, 22 Jul 2019 11:52:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5968E000E
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:52:46 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id d135so30149049ywd.0
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:52:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=7DO9MTBRdFEkevurnUIdoXlyP4AeeNGwU382CMy2jFs=;
        b=G01it6mFMW5viAWkqrSQrC+4yiM/EXWqf5zwpCIR31hgDb9Zh7/AELHO9NJw2RyaIu
         bIfyxPmRPvh+0UwhtZNt6PpsQOIOa6TL7ZN1hHziTCKO8iBYThkZz2R2xHydHEvwwRkF
         aVyZt9G2v9tMK7hR+mtUhstZyeqjZV+dcsRjO8QqXjcL7gGVoXm6H7jipSBnWpGOcJlp
         DaIKSgtbNt5rxmf+SbsKbslnOGdoBV4k6aCPDe9HBGS6fbSzipMAi5g4ZMhETQRUpUAq
         QNoJdPoEdYF54bX+XbaYvhVly95fE2WmsaRPpXS+niP7CtyP8UB5Q2nJOqEwtykxr9sl
         5aTQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAU+yB8O8rmCq9xDynXaDpdIoV1dKa9yhQV3jXa472m4UPBN0EYP
	UXnXmNF6vqEMhvCwby1IU4E91TffvTQolYa49zZDFrXHnjGxTPZgF3T9pGGac+BJASFtIGybTyT
	X7W3LF8gdNvu+aQSHLihEZqK+pgspp5f5ifs+09tvz6QFSt6hc4u1lRm6XKMHzuw=
X-Received: by 2002:a25:d907:: with SMTP id q7mr952042ybg.348.1563810766235;
        Mon, 22 Jul 2019 08:52:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3duA8p1fMFZt5bo7EjoT3Rpv8qmYNAf5tOrMA62ClnQoacH/h1OT+j5LfGEvzSK4BL7HB
X-Received: by 2002:a25:d907:: with SMTP id q7mr952013ybg.348.1563810765646;
        Mon, 22 Jul 2019 08:52:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810765; cv=none;
        d=google.com; s=arc-20160816;
        b=f2VjWua6pv1b1901awkk2TQWf7nFfe+SZzHgbWuDcmoDBy0PSXvA53EKDSZ8n3vOQ+
         u555aCRK8rnquFkH1CDbSRB8UkTcBIZChxlirsrsxnA5phpNr3QAwmqz60cjZ0JrQOO8
         NYRSbzxpe2h52dC0yUVNTGZ6d7WRnGnPybzWmHOFNUoz+sR+aoDYHU4PctyL2iPcH9E7
         QLj9pDJ5ubulv/TV99rFidSmiXClvWYNWfJMYKoTv01f2MMZZ70kv1Ax1SUVbO7uL51F
         85Jn8ZCeWtHmFwAXRDexWlERvLOvoZN8BM/6XcwexHoXjyFTwg9U+Ea1sGYanVW99EA4
         ftbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=7DO9MTBRdFEkevurnUIdoXlyP4AeeNGwU382CMy2jFs=;
        b=FUo+ZMmt169zB6UqEaxpzz1LcLFJivik7869KPhJCI0bhRUUo10swzVXcvu8Im8Y9s
         tim1DQjVTaNIR0xZwcj0/d56YZmLWtimggR1nJbkXmCdaZNcW+/An2poyc8G+4wY5f4D
         D+C6zuZJ1F0aB5TbqmNXw9IKNpGXvoCsX1pZDZca/JuubxBgzxlZ4bTWKhWwQ32lw/io
         mEepsM+6iB2PJL9gT2cKmuuRBn6XlNbqSH/9fbsrdp0BinNt/e8ZBQv4KbMhYzmKKPOq
         //VX7uHi5dh35NMZgohP03k7CplzWhM/FedKXrJfjeqPSjRLBA0nNf8D8g+3+HWrETQz
         LCKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s189si7333190ywb.67.2019.07.22.08.52.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 08:52:45 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6MFq0kv108615
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:52:45 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2twfa5tq4y-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:52:45 -0400
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 22 Jul 2019 16:52:44 +0100
Received: from b01cxnp23033.gho.pok.ibm.com (9.57.198.28)
	by e11.ny.us.ibm.com (146.89.104.198) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 22 Jul 2019 16:52:35 +0100
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6MFqYJI47055222
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 22 Jul 2019 15:52:34 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 90AB8B2068;
	Mon, 22 Jul 2019 15:52:34 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3E140B205F;
	Mon, 22 Jul 2019 15:52:34 +0000 (GMT)
Received: from paulmck-ThinkPad-W541 (unknown [9.85.189.166])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Mon, 22 Jul 2019 15:52:34 +0000 (GMT)
Received: by paulmck-ThinkPad-W541 (Postfix, from userid 1000)
	id BB14116C9087; Mon, 22 Jul 2019 08:52:35 -0700 (PDT)
Date: Mon, 22 Jul 2019 08:52:35 -0700
From: "Paul E. McKenney" <paulmck@linux.ibm.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Matthew Wilcox <willy@infradead.org>, aarcange@redhat.com,
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
 <20190722115149.GY14271@linux.ibm.com>
 <20190722134152.GA13013@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722134152.GA13013@ziepe.ca>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-TM-AS-GCONF: 00
x-cbid: 19072215-2213-0000-0000-000003B4493B
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011475; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000287; SDB=6.01235877; UDB=6.00651336; IPR=6.01017228;
 MB=3.00027839; MTD=3.00000008; XFM=3.00000015; UTC=2019-07-22 15:52:42
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19072215-2214-0000-0000-00005F585F3F
Message-Id: <20190722155235.GF14271@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-22_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=621 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907220176
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 10:41:52AM -0300, Jason Gunthorpe wrote:
> On Mon, Jul 22, 2019 at 04:51:49AM -0700, Paul E. McKenney wrote:
> 
> > > > > Would it make sense to have call_rcu() check to see if there are many
> > > > > outstanding requests on this CPU and if so process them before returning?
> > > > > That would ensure that frequent callers usually ended up doing their
> > > > > own processing.
> > > > 
> > > > Unfortunately, no.  Here is a code fragment illustrating why:
> 
> That is only true in the general case though, kfree_rcu() doesn't have
> this problem since we know what the callback is doing. In general a
> caller of kfree_rcu() should not need to hold any locks while calling
> it.

Good point, at least as long as the slab allocators don't call kfree_rcu()
while holding any of the slab locks.

However, that would require a separate list for the kfree_rcu() callbacks,
and concurrent access to those lists of kfree_rcu() callbacks.  So this
might work, but would add some complexity and also yet another restriction
between RCU and another kernel subsystem.  So I would like to try the
other approaches first, for example, the time-based approach in my
prototype and Eric Dumazet's more polished patch.

But the immediate-invocation possibility is still there if needed.

> We could apply the same idea more generally and have some
> 'call_immediate_or_rcu()' which has restrictions on the caller's
> context.
> 
> I think if we have some kind of problem here it would be better to
> handle it inside the core code and only require that callers use the
> correct RCU API.

Agreed.  Especially given that there are a number of things that can
be done within RCU.

> I can think of many places where kfree_rcu() is being used under user
> control..

And same for call_rcu().

And this is not the first time we have run into this.  The last time
was about 15 years ago, if I remember correctly, and that one led to
some of the quiescent-state forcing and callback-invocation batch size
tricks still in use today.  My only real surprise is that it took so
long for this to come up again.  ;-)

Please note also that in the common case on default configurations,
callback invocation is done on the CPU that posted the callback.
This means that callback invocation normally applies backpressure
to the callback-happy workload.

So why then is there a problem?

The problem is not the lack of backpressure, but rather that the
scheduling of callback invocation needs to be a bit more considerate
of the needs of the rest of the system.  In the common case, that is.
Except that the uncommon case is real-time configurations, in which care
is needed anyway.  But I am in the midst of helping those out as well,
details on the "dev" branch of -rcu.

							Thanx, Paul

