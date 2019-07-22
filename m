Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D69D6C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:55:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AE03218EA
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:55:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AE03218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E4C78E0019; Mon, 22 Jul 2019 11:55:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 395A68E000E; Mon, 22 Jul 2019 11:55:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25E5F8E0019; Mon, 22 Jul 2019 11:55:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 037E58E000E
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:55:44 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id x203so3273171ybg.9
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:55:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=5Vz2WbSDvmn8vKHyoNpM2NehEiszfB15xqaCIu+Cj0g=;
        b=NDn56uEaMopj1fVLDZ/ckKXyFL5dLabxRKX3mpgSYr/SXkLqxxN36oSQSi6PLRzB+r
         jT5SM4TN91CaxFQ/9b1aaoIuNRuK5PUPojREjdyAGvQupTwBiCwuzwPzDLsbbJ4sZypH
         0djfVE4JF0SAvvITszrAF+pOGTFYTHERv60QkPIEqUsCSlypDPa959KybuSEUdKfRMHg
         MX1fOwKDIoKAB2IDabsDsdF4gOOuwxJosxhXGJaQ06Bme/kQoeiXlGz5qK9iI3ck4QGo
         VBmYXwpO28fO4skrjy339+LNVD33/eYvIjBggE9B3WY1bl8qW7VwyIVvy9t9rgFPA/s3
         4LiQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWlpOEbjr0c/vpZXRTOlQDPrNk+A+MIZCmUPGNwTMzJmnTX+vSN
	TxOEciF2Fxn2SW6N2Nw7JZ4g+EtmF11PJ/rKyiS/dpg1REjmHm5N9YXJnbSfYnU0ZXcW5Gmlmrf
	r+SSkkKaDa+Vaw/ABr+SPYFKU8yX6xpKOJZMrVEMIr3qCrVkR/QxHbGrDZ0R+vmo=
X-Received: by 2002:a5b:307:: with SMTP id j7mr41733017ybp.316.1563810943777;
        Mon, 22 Jul 2019 08:55:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwphDYAHEShC8tUiiiNCg0mTduTUizxwty2EZE+X3EOMwRbkf5wZHJKqkIKusEfsilK/zLK
X-Received: by 2002:a5b:307:: with SMTP id j7mr41732992ybp.316.1563810943294;
        Mon, 22 Jul 2019 08:55:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810943; cv=none;
        d=google.com; s=arc-20160816;
        b=p7FfI6eGvkBKoBjHN/XOUC8Qm9EU31YYktE0zNHVJYE25QpMFmfJClFeh2EluukFOC
         qFDWaMfxR4HxydzqmQi2190UhWEecFmszKE3Rn5FLyiFrxtSYyhpZfF6SC1Qpj8tT4aB
         v/keVdMGxsBKRlJN8+ziwKJ59SFAhiFtENfOBClZh0E0guNkJYmm5UKYWFBNzb+FSq7f
         ezd7U5/LiOATPBazOhZsBzjtTtrWVDP8UrbznbCdPyh2CwodCHcJMZA4mHqE9BvrW2VW
         jxiv0aTXkcd009OGSkt3HawVmxIin5kF4sdd5AZWlcU/+N4+JuYLvagzfzqcsOAbHKxb
         7h6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=5Vz2WbSDvmn8vKHyoNpM2NehEiszfB15xqaCIu+Cj0g=;
        b=UZ8y7fwOc6/oTufcp0gB40czZRnYa0Cjnu1iFDzhiPGE13ixUiSLa31/pwiAvgbR6N
         PmBncBfoxxVGkbxA7Iggz/BztqJdUhOksvf4d7V/F+GXr5qpPadef6qqEtAnNJ5LXVpV
         UaUOtweDEtGuxyLrR9YxafhbTWa8ENyeT3h/55EQ0p7VsXsg5PryZS0ysCw7JexrZaY3
         t6uteKtjK/07LM6R6IOOF3alA0hwtAfRsOzIslKMXPUiOwaYsmBJ78hTfjBaugQQMUrY
         7lG6DFv6e6oWLWeUwBVf/gRm89I8WRqtPhn9a354dHNDhTxFPAtcMRt/yrKvM5yZPM8E
         s8vQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 3si13137218ybc.288.2019.07.22.08.55.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 08:55:43 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6MFqYee033362
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:55:43 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2twfpn1pbn-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:55:42 -0400
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 22 Jul 2019 16:55:42 +0100
Received: from b01cxnp22035.gho.pok.ibm.com (9.57.198.25)
	by e16.ny.us.ibm.com (146.89.104.203) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 22 Jul 2019 16:55:33 +0100
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6MFtWhQ53412302
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 22 Jul 2019 15:55:32 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D3095B206A;
	Mon, 22 Jul 2019 15:55:32 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9353EB2068;
	Mon, 22 Jul 2019 15:55:32 +0000 (GMT)
Received: from paulmck-ThinkPad-W541 (unknown [9.85.189.166])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Mon, 22 Jul 2019 15:55:32 +0000 (GMT)
Received: by paulmck-ThinkPad-W541 (Postfix, from userid 1000)
	id 1D5F416C29D7; Mon, 22 Jul 2019 08:55:34 -0700 (PDT)
Date: Mon, 22 Jul 2019 08:55:34 -0700
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
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <20190721081933-mutt-send-email-mst@kernel.org>
 <20190721131725.GR14271@linux.ibm.com>
 <20190721210837.GC363@bombadil.infradead.org>
 <20190721233113.GV14271@linux.ibm.com>
 <20190722151439.GA247639@google.com>
 <20190722114612-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722114612-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-TM-AS-GCONF: 00
x-cbid: 19072215-0072-0000-0000-0000044BEC7B
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011475; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000287; SDB=6.01235879; UDB=6.00651337; IPR=6.01017229;
 MB=3.00027839; MTD=3.00000008; XFM=3.00000015; UTC=2019-07-22 15:55:40
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19072215-0073-0000-0000-00004CBC4749
Message-Id: <20190722155534.GG14271@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-22_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907220176
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 11:47:24AM -0400, Michael S. Tsirkin wrote:
> On Mon, Jul 22, 2019 at 11:14:39AM -0400, Joel Fernandes wrote:
> > [snip]
> > > > Would it make sense to have call_rcu() check to see if there are many
> > > > outstanding requests on this CPU and if so process them before returning?
> > > > That would ensure that frequent callers usually ended up doing their
> > > > own processing.
> > 
> > Other than what Paul already mentioned about deadlocks, I am not sure if this
> > would even work for all cases since call_rcu() has to wait for a grace
> > period.
> > 
> > So, if the number of outstanding requests are higher than a certain amount,
> > then you *still* have to wait for some RCU configurations for the grace
> > period duration and cannot just execute the callback in-line. Did I miss
> > something?
> > 
> > Can waiting in-line for a grace period duration be tolerated in the vhost case?
> > 
> > thanks,
> > 
> >  - Joel
> 
> No, but it has many other ways to recover (try again later, drop a
> packet, use a slower copy to/from user).

True enough!  And your idea of taking recovery action based on the number
of callbacks seems like a good one while we are getting RCU's callback
scheduling improved.

By the way, was this a real problem that you could make happen on real
hardware?  If not, I would suggest just letting RCU get improved over
the next couple of releases.

If it is something that you actually made happen, please let me know
what (if anything) you need from me for your callback-counting EBUSY
scheme.

							Thanx, Paul

