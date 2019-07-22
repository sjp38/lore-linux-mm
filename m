Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7B76C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 16:26:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACF522190F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 16:26:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACF522190F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 331568E0009; Mon, 22 Jul 2019 12:26:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E2828E0001; Mon, 22 Jul 2019 12:26:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AB048E0009; Mon, 22 Jul 2019 12:26:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id DBC2A8E0001
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 12:26:02 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id f2so20125615plr.0
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 09:26:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=GiyazXfMu9wmGR9Wq1p0H+vBmEXYh6t5jkGGZ9OjhEA=;
        b=tuxWPi8P68uYhhlEsPqjjRnPuEoL0em6/k5n8M1Ua2luvi3G6O3cPd1TsL4nXpuwwX
         FnEIf0+Cn1Y+erivdCJ3pDL8TBTamRn+rjanM6MF4tTeNrq9JRlMh3IXOEU6ziFnfWIt
         50nVuPtE+r+QWGSsl/mJKNX0A+j1tf73XlHAcsK+be7AxNMcYc7EKUC9a5iq86efyDNW
         FnF4q0uLJq3hwhqM4ii2W6hLV8wyEgbZ/K5noMKO3XASeOscz6LigJ4GUszdnPWlEeKs
         nnGlc4BXrXatFhpxg8pxNQUSQKiCrxND6CBGxcagyR59k8OaI380oTPZhg9EO4c2eP3v
         PeaQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVGTAXdAz4TYlz1sDeAqmL5C6YQhFXPEdRB42kaZszsMWIPfrPM
	UwfGHxFTYHYgFXxH2UeYN5nqKHhI6LMF12oEWtvxTYaNllvh2ZGqL7X5SsY0eL2lMUx2PKGnDyU
	XHZE0zR5JpwLBmXwtUsFe6tHj0AbsHivaFDyiaRCFnV3t81E6Oncc4CS89893vqg=
X-Received: by 2002:a17:90a:9488:: with SMTP id s8mr79878011pjo.2.1563812762562;
        Mon, 22 Jul 2019 09:26:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfZrhBLA/RKZQj2H1y5LPvnKBf5rYZtrewsylcrwWDyphmAFByf07l51aCVnUXCW4MjGb0
X-Received: by 2002:a17:90a:9488:: with SMTP id s8mr79877931pjo.2.1563812761593;
        Mon, 22 Jul 2019 09:26:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563812761; cv=none;
        d=google.com; s=arc-20160816;
        b=Yr4suqUaIze5dYtOznYCUYmWPktl8X9BpWSCp/93lfzZn9w1d1eDgJMwp8fsa6/V08
         9vr9/umCFQWjTkcHQsiytY2o+ieuegspzNwqmeZ6XlS8iSOeZVXXGIIpBnA/GNwDyM6N
         8rBN8hveG1kv10Dx9krzqudQ25KuSU93JILqxglh3to/aXrpnNV/7g/W59IYspqbrlCo
         MGgeFX/kYn+PxVU1NiCxPZcOBNLjm4l3qv0DjrbEKD1pwqOGDPy4w05Uoy+haC0RSeNl
         sVk/2MDUuUNP+zyC9HT3S6am2Py/iiL4WRv6rOlTudEXFk5bP8zKbVJmK6hC2hQJrx/k
         MgAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=GiyazXfMu9wmGR9Wq1p0H+vBmEXYh6t5jkGGZ9OjhEA=;
        b=LcP9MZ9Q7pzX5Zvn2ky53LGxAUxOgRmYT6Up1V6BF8zc7t7hKNhmoT7KKpvBzIgxqh
         j6caHGS/GGTliiWKj5lvHv7EWHQGd4lEDXXnfRo+5VZJdPpvnlZfjf1IY0nKQoR/2Plm
         04fCr/z1jRzfe7vCm5UrJfHe2GVm27Jh4YmGO7pW/ha3N9CBXKLvvWrbzfkS6sfIZp1z
         fDqV7xMojiAy2squ8JSVIWP4gY5H5wPJJY3NxS6XIKVn1KNfFW/JPPC25/MILPas76P7
         I1pL5tBcLlsOt+zbQSigcsmgqc/vSEaQlTKxhsMwahC9TkEireLIpGfDrmYgZ2pGQAIY
         7/0w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s3si10203680pgq.392.2019.07.22.09.26.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 09:26:01 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6MGLnHL075481
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 12:26:01 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2twft6jrdm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 12:26:00 -0400
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 22 Jul 2019 17:25:59 +0100
Received: from b01cxnp23034.gho.pok.ibm.com (9.57.198.29)
	by e13.ny.us.ibm.com (146.89.104.200) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 22 Jul 2019 17:25:51 +0100
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6MGPogJ49349098
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 22 Jul 2019 16:25:50 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 78428B2070;
	Mon, 22 Jul 2019 16:25:50 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2FDD0B2065;
	Mon, 22 Jul 2019 16:25:50 +0000 (GMT)
Received: from paulmck-ThinkPad-W541 (unknown [9.85.189.166])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Mon, 22 Jul 2019 16:25:50 +0000 (GMT)
Received: by paulmck-ThinkPad-W541 (Postfix, from userid 1000)
	id B68CC16C29D7; Mon, 22 Jul 2019 09:25:51 -0700 (PDT)
Date: Mon, 22 Jul 2019 09:25:51 -0700
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
References: <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <20190721081933-mutt-send-email-mst@kernel.org>
 <20190721131725.GR14271@linux.ibm.com>
 <20190721210837.GC363@bombadil.infradead.org>
 <20190721233113.GV14271@linux.ibm.com>
 <20190722151439.GA247639@google.com>
 <20190722114612-mutt-send-email-mst@kernel.org>
 <20190722155534.GG14271@linux.ibm.com>
 <20190722120011-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722120011-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-TM-AS-GCONF: 00
x-cbid: 19072216-0064-0000-0000-00000401FECB
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011475; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000287; SDB=6.01235889; UDB=6.00651343; IPR=6.01017239;
 MB=3.00027839; MTD=3.00000008; XFM=3.00000015; UTC=2019-07-22 16:25:58
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19072216-0065-0000-0000-00003E5FF2DB
Message-Id: <20190722162551.GK14271@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-22_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907220182
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 12:13:40PM -0400, Michael S. Tsirkin wrote:
> On Mon, Jul 22, 2019 at 08:55:34AM -0700, Paul E. McKenney wrote:
> > On Mon, Jul 22, 2019 at 11:47:24AM -0400, Michael S. Tsirkin wrote:
> > > On Mon, Jul 22, 2019 at 11:14:39AM -0400, Joel Fernandes wrote:
> > > > [snip]
> > > > > > Would it make sense to have call_rcu() check to see if there are many
> > > > > > outstanding requests on this CPU and if so process them before returning?
> > > > > > That would ensure that frequent callers usually ended up doing their
> > > > > > own processing.
> > > > 
> > > > Other than what Paul already mentioned about deadlocks, I am not sure if this
> > > > would even work for all cases since call_rcu() has to wait for a grace
> > > > period.
> > > > 
> > > > So, if the number of outstanding requests are higher than a certain amount,
> > > > then you *still* have to wait for some RCU configurations for the grace
> > > > period duration and cannot just execute the callback in-line. Did I miss
> > > > something?
> > > > 
> > > > Can waiting in-line for a grace period duration be tolerated in the vhost case?
> > > > 
> > > > thanks,
> > > > 
> > > >  - Joel
> > > 
> > > No, but it has many other ways to recover (try again later, drop a
> > > packet, use a slower copy to/from user).
> > 
> > True enough!  And your idea of taking recovery action based on the number
> > of callbacks seems like a good one while we are getting RCU's callback
> > scheduling improved.
> > 
> > By the way, was this a real problem that you could make happen on real
> > hardware?
> 
> >  If not, I would suggest just letting RCU get improved over
> > the next couple of releases.
> 
> So basically use kfree_rcu but add a comment saying e.g. "WARNING:
> in the future callers of kfree_rcu might need to check that
> not too many callbacks get queued. In that case, we can
> disable the optimization, or recover in some other way.
> Watch this space."

That sounds fair.

> > If it is something that you actually made happen, please let me know
> > what (if anything) you need from me for your callback-counting EBUSY
> > scheme.
> > 
> > 							Thanx, Paul
> 
> If you mean kfree_rcu causing OOM then no, it's all theoretical.
> If you mean synchronize_rcu stalling to the point where guest will OOPs,
> then yes, that's not too hard to trigger.

Is synchronize_rcu() being stalled by the userspace loop that is invoking
your ioctl that does kfree_rcu()?  Or instead by the resulting callback
invocation?

							Thanx, Paul

