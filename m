Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2DFCC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 18:58:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79CAA2199C
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 18:58:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79CAA2199C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1A656B0007; Mon, 22 Jul 2019 14:58:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECC938E0003; Mon, 22 Jul 2019 14:58:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBA6E8E0001; Mon, 22 Jul 2019 14:58:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F6AB6B0007
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 14:58:49 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 91so20341109pla.7
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:58:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=xGVy8YwoFmT0UcDBgQoRUAKiMQLGmIeUq2f7WeJTmMM=;
        b=TaD5pYig8/cjY3702HpGfCWvylrQhGNH4pg6d/gBJSnuJNTw/OkHDoJC7gI4iknb0y
         Fip/4r9WNSENIl4pMnYNdLWyqItaxUdWVuqbEd7GWkL3oOCjOOCxlApFWwXz1yRP5unK
         y5RtvwTezE160CNpXLyY/BIkieQ1jmLBLoN32vGzTWUxJw+mJeQkzAx4Rdkuq7wTb7Q7
         R1Dq3E9LOeb3RMt3MDeL4FudZDtC3uioMfnS21JCm21LIclmQ2iVY+Z1pBbNLSlKNNhR
         riJHgkxtq6fsPXNim+Af33P+x6mx7ScO01lDrcMWJcdNPVoxlTVdcTATDbaiXEpUOOPO
         MqAA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVdxX9Go2yWrVuq4ivKd2W98NPggrs9ANrzHMyJFyaYxzv+v4HZ
	EwuY8waJTPMLrjrmpgPbMAybrBBaSNoVOPLa1INIK5vsCoiiuEEFOWpUy3G5BiBvB2lCaZ4jwu4
	HbLOivjl9rLAsEOgssddJrEGZKxhEZLwf7WR2CHEDXd6jOHOoknzEnH4Qp2IJPLc=
X-Received: by 2002:a17:90a:2305:: with SMTP id f5mr82417742pje.128.1563821929306;
        Mon, 22 Jul 2019 11:58:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwv7G4G+rWCEF0K7yi0AwCSlNLLhj82ypM2uhPKCR2nqxpCCcd6qlPvZgtRuMH9pOkPPC/4
X-Received: by 2002:a17:90a:2305:: with SMTP id f5mr82417674pje.128.1563821928256;
        Mon, 22 Jul 2019 11:58:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563821928; cv=none;
        d=google.com; s=arc-20160816;
        b=uD9cmk1t0apLAyYEhn/NIeyKbB6F8Tqw4oTQifWlJNejxblS2B6MOMms07B+6Xh8oX
         5WeeLZjjhFdjBP4y1zDBvb19C4fmaRTGjE/JmAXWo9mpfEl7BWFQdLlhMbXmvDaityLF
         zRC8VyMZ9JokxoAL3WhzVaiOuiCfWnuBSNo7LcnSMUQgIJvQoNTJgdyMqbVtnTtskfWW
         1/adVIzsZixiozdixCipB6T0TvuA3AzeIuxVm+J7WOU6M3fESNl3QUknw9iSan2jObID
         cMFEkFkvXrM+tzHyg5JlvfHFlxE9Vl3CNHhsVUjEWGK5sMvDIj2cM6hxTTIyOsmVseVf
         Rkmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=xGVy8YwoFmT0UcDBgQoRUAKiMQLGmIeUq2f7WeJTmMM=;
        b=TuCE4smuhEv02Gqqeq5qIEfhoypUs18Qog4gDRtLJgaGCj+t+DR/8Cvc6+VtAz2Ax3
         Bbpt/ngaldUSiE6kjBnRA6UaPdcwsK6rbWHzZ8SD8NAS8y4012ydlBcPrpu3hyl62EZI
         9QzxYg+KJGqsu/Hz4/zuK6wN7+mghBhdIEUDNH+fvjeA3pxrdyPhigOntzYSp+nTvUUM
         oA7RZDbp7hXB6lK/qjsJ7sf0wOEV1Egr9/Z1ncPmxrCPSmQ0e+DEFk6XnvMnkT83U3Lf
         futTM6PHjpyJXlGLfSZtGLl2+GVcFl6hzaNGSq7ZugOgxB2D+CXWRoCvjf/BbMEjCbgx
         g7rw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i23si10301527pfa.196.2019.07.22.11.58.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 11:58:48 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6MIfWmn035327
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 14:58:47 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2twhpkb0ex-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 14:58:47 -0400
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 22 Jul 2019 19:58:46 +0100
Received: from b01cxnp22036.gho.pok.ibm.com (9.57.198.26)
	by e12.ny.us.ibm.com (146.89.104.199) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 22 Jul 2019 19:58:38 +0100
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6MIwbR034996668
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 22 Jul 2019 18:58:37 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id EF4E1B206B;
	Mon, 22 Jul 2019 18:58:36 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A7660B206E;
	Mon, 22 Jul 2019 18:58:36 +0000 (GMT)
Received: from paulmck-ThinkPad-W541 (unknown [9.85.189.166])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Mon, 22 Jul 2019 18:58:36 +0000 (GMT)
Received: by paulmck-ThinkPad-W541 (Postfix, from userid 1000)
	id 61AF716C2A41; Mon, 22 Jul 2019 11:58:38 -0700 (PDT)
Date: Mon, 22 Jul 2019 11:58:38 -0700
From: "Paul E. McKenney" <paulmck@linux.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Joel Fernandes <joel@joelfernandes.org>,
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
References: <20190721081933-mutt-send-email-mst@kernel.org>
 <20190721131725.GR14271@linux.ibm.com>
 <20190721210837.GC363@bombadil.infradead.org>
 <20190721233113.GV14271@linux.ibm.com>
 <20190722151439.GA247639@google.com>
 <20190722114612-mutt-send-email-mst@kernel.org>
 <20190722155534.GG14271@linux.ibm.com>
 <20190722120011-mutt-send-email-mst@kernel.org>
 <20190722162551.GK14271@linux.ibm.com>
 <20190722123016-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722123016-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-TM-AS-GCONF: 00
x-cbid: 19072218-0060-0000-0000-0000036406C2
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011476; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000287; SDB=6.01235939; UDB=6.00651373; IPR=6.01017290;
 MB=3.00027841; MTD=3.00000008; XFM=3.00000015; UTC=2019-07-22 18:58:44
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19072218-0061-0000-0000-00004A404C02
Message-Id: <20190722185838.GN14271@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-22_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907220206
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 12:32:17PM -0400, Michael S. Tsirkin wrote:
> On Mon, Jul 22, 2019 at 09:25:51AM -0700, Paul E. McKenney wrote:
> > On Mon, Jul 22, 2019 at 12:13:40PM -0400, Michael S. Tsirkin wrote:
> > > On Mon, Jul 22, 2019 at 08:55:34AM -0700, Paul E. McKenney wrote:
> > > > On Mon, Jul 22, 2019 at 11:47:24AM -0400, Michael S. Tsirkin wrote:
> > > > > On Mon, Jul 22, 2019 at 11:14:39AM -0400, Joel Fernandes wrote:
> > > > > > [snip]
> > > > > > > > Would it make sense to have call_rcu() check to see if there are many
> > > > > > > > outstanding requests on this CPU and if so process them before returning?
> > > > > > > > That would ensure that frequent callers usually ended up doing their
> > > > > > > > own processing.
> > > > > > 
> > > > > > Other than what Paul already mentioned about deadlocks, I am not sure if this
> > > > > > would even work for all cases since call_rcu() has to wait for a grace
> > > > > > period.
> > > > > > 
> > > > > > So, if the number of outstanding requests are higher than a certain amount,
> > > > > > then you *still* have to wait for some RCU configurations for the grace
> > > > > > period duration and cannot just execute the callback in-line. Did I miss
> > > > > > something?
> > > > > > 
> > > > > > Can waiting in-line for a grace period duration be tolerated in the vhost case?
> > > > > > 
> > > > > > thanks,
> > > > > > 
> > > > > >  - Joel
> > > > > 
> > > > > No, but it has many other ways to recover (try again later, drop a
> > > > > packet, use a slower copy to/from user).
> > > > 
> > > > True enough!  And your idea of taking recovery action based on the number
> > > > of callbacks seems like a good one while we are getting RCU's callback
> > > > scheduling improved.
> > > > 
> > > > By the way, was this a real problem that you could make happen on real
> > > > hardware?
> > > 
> > > >  If not, I would suggest just letting RCU get improved over
> > > > the next couple of releases.
> > > 
> > > So basically use kfree_rcu but add a comment saying e.g. "WARNING:
> > > in the future callers of kfree_rcu might need to check that
> > > not too many callbacks get queued. In that case, we can
> > > disable the optimization, or recover in some other way.
> > > Watch this space."
> > 
> > That sounds fair.
> > 
> > > > If it is something that you actually made happen, please let me know
> > > > what (if anything) you need from me for your callback-counting EBUSY
> > > > scheme.
> > > 
> > > If you mean kfree_rcu causing OOM then no, it's all theoretical.
> > > If you mean synchronize_rcu stalling to the point where guest will OOPs,
> > > then yes, that's not too hard to trigger.
> > 
> > Is synchronize_rcu() being stalled by the userspace loop that is invoking
> > your ioctl that does kfree_rcu()?  Or instead by the resulting callback
> > invocation?
> 
> Sorry, let me clarify.  We currently have synchronize_rcu in a userspace
> loop. I have a patch replacing that with kfree_rcu.  This isn't the
> first time synchronize_rcu is stalling a VM for a long while so I didn't
> investigate further.

Ah, so a bunch of synchronize_rcu() calls within a single system call
inside the host is stalling the guest, correct?

If so, one straightforward approach is to do an rcu_barrier() every
(say) 1000 kfree_rcu() calls within that loop in the system call.
This will decrease the overhead by almost a factor of 1000 compared to
a synchronize_rcu() on each trip through that loop, and will prevent
callback overload.

Or if the situation is different (for example, the guest does a long
sequence of system calls, each of which does a single kfree_rcu() or
some such), please let me know what the situation is.

							Thanx, Paul

