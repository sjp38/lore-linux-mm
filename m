Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54C9CC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:54:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0105220842
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:54:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0105220842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8234E8E0003; Tue, 12 Feb 2019 10:54:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D2A08E0001; Tue, 12 Feb 2019 10:54:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69B1D8E0003; Tue, 12 Feb 2019 10:54:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D21E8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:54:51 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id v82so2745685pfj.9
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:54:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=s3UfIOXByfgCwznv4xF7iyVkVuf3W/Scl8wbVrUV+Gs=;
        b=EIfOPYfKLDpeKufY7PR70/Uo2Y/oknmVkqvqRBv6Va7MDv0SsnvwRPRlJ6/jYQ0C3y
         T5wf4oh7BTQtjpnpCH+hs8YhskUf5v8CNl87kaGm6dRYtJ/QWQ9fW+c4y2rtJOHsk39T
         P320efLQZZ0uWKPjwqx2NakQaTz3jQed2fpqjzG8gJEM+od95kb1W0FSVMhZ/fBBCgrc
         d6qApIHAWTy/a+GufRUNpbMkk/UFrAX9cYZbFkXk+18MdksVyD2FzqXa+xO702qXh0Fl
         LT/RU1Eimi7VvRbhxjCh9HvBB1YhHuSp5J7x3hnqXGvHT5nBOtJ+zh2+T2M8ke7bYnat
         GBNg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZ/KV6f93kTmSCASgFoX21U6ck8R8a0kmzSkKrbY3lN9xCSAd1E
	/8x7xvOVBHz3x945mLmF/IB5VJrsMc3nKQ09hitxGQvVEPve/X66tXvwV6gRXp6xradoV/S4fUk
	m9VqZSD6Ov364Si7gFiuLL2c21XVphRqhtmo1FE1ls2qw5IW3vyuVemEbEjOFzRs=
X-Received: by 2002:a62:f84a:: with SMTP id c10mr1520405pfm.18.1549986890766;
        Tue, 12 Feb 2019 07:54:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaUQUrhT0qmh0x9w7dvtKKuILclg1iMsDQ16u8cag+l5u4siJQVg+oCJMBvzWZoNFBXSyO9
X-Received: by 2002:a62:f84a:: with SMTP id c10mr1520364pfm.18.1549986889783;
        Tue, 12 Feb 2019 07:54:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549986889; cv=none;
        d=google.com; s=arc-20160816;
        b=GD20+FIGD/Ga4Pk6suiVJ21ZmwX56e1DKKlw6peChU6v6OYJjA+0Shg2N/3huDeBAS
         +Vj+90lU1MAECQ0zLq8oiGClgsckghOkG8hSiGHuvSMItvnJT+TsRQjc12GljJfLqjO1
         QyXUbcCpav/iJL1rN7Ba/vX67z7vLkkmVwmrzs7N3BwdLunmNxKTCEMdG0JEh85erNMb
         Lgx9v48HWQFxVvcWc4wagHHJi9RPXGL1H33Z35YcXleEkw2WGfRV98CLsXwlvTLoJlEL
         SjrSLayzd+KZukDQrC7hz8m5kW6p+grQ/40BDrbCbVHULEs1iy1UkcaFYAFIMDR8yVPy
         guHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=s3UfIOXByfgCwznv4xF7iyVkVuf3W/Scl8wbVrUV+Gs=;
        b=F9y+CYbGf2LOlUuVCa0i2m7V0stw5edYkYv4NAs49PYLH7+WX524zuLQtIVcEQXizp
         amw0gMUH3zASFfyzC/XHj+TBh1fSFJ2wPdGK6tXLXP9FqV56j9XyPxpcaWTXcKm/eCtJ
         vGcrWIG2RvYKGwS7RHe88HRnB60fETwTNpBFBHqj8RKzE9/TBfoMpzVwVmSaxAIXpswh
         a4mrZHOvCiUsCi0bZ6KKGDcBlOoiwSUDip6HYaE/OAOQsa6n84qjPm7wGK8CKYjeAidA
         QP75M8EATyKdGa+wKwuEybmFnv0WdPzmkXhidlFAvSvOyDBCfrNBLLvXlS0Z0pNKmkNi
         oqrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k20si12997357pls.116.2019.02.12.07.54.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 07:54:49 -0800 (PST)
Received-SPF: neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1CFsY3E121064
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:54:49 -0500
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qm0qbhjdj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:54:48 -0500
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 12 Feb 2019 15:54:45 -0000
Received: from b01cxnp22035.gho.pok.ibm.com (9.57.198.25)
	by e13.ny.us.ibm.com (146.89.104.200) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 12 Feb 2019 15:54:42 -0000
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1CFsfFg23003282
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Feb 2019 15:54:41 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 55371B205F;
	Tue, 12 Feb 2019 15:54:41 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 27426B2064;
	Tue, 12 Feb 2019 15:54:41 +0000 (GMT)
Received: from paulmck-ThinkPad-W541 (unknown [9.70.82.41])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Tue, 12 Feb 2019 15:54:41 +0000 (GMT)
Received: by paulmck-ThinkPad-W541 (Postfix, from userid 1000)
	id 49F0D16C4009; Tue, 12 Feb 2019 07:54:41 -0800 (PST)
Date: Tue, 12 Feb 2019 07:54:41 -0800
From: "Paul E. McKenney" <paulmck@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <lkp@intel.com>, Suren Baghdasaryan <surenb@google.com>,
        kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>,
        Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [linux-next:master 6618/6917] kernel/sched/psi.c:1230:13:
 sparse: error: incompatible types in comparison expression (different
 address spaces)
Reply-To: paulmck@linux.ibm.com
References: <201902080231.RZbiWtQ6%fengguang.wu@intel.com>
 <20190208151441.4048e6968579dd178b259609@linux-foundation.org>
 <20190209074407.GE4240@linux.ibm.com>
 <20190211170037.f227b544efd64ecef56357c0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211170037.f227b544efd64ecef56357c0@linux-foundation.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-TM-AS-GCONF: 00
x-cbid: 19021215-0064-0000-0000-000003A79B0D
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010583; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000279; SDB=6.01160036; UDB=6.00605416; IPR=6.00940588;
 MB=3.00025547; MTD=3.00000008; XFM=3.00000015; UTC=2019-02-12 15:54:44
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021215-0065-0000-0000-00003C64768E
Message-Id: <20190212155441.GI4240@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-12_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902120113
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 05:00:37PM -0800, Andrew Morton wrote:
> > > 
> > > Paul, can you please shed light?
> > 
> > First, please avoid using rcu_dereference_raw() where possible.  It is
> > intended for situations where the developer cannot easily state what
> > is to be protecting access to an RCU-protected data structure.  So...
> > 
> > 1.	If the access needs to be within an RCU read-side critical
> > 	section, use rcu_dereference().  With the new consolidated
> > 	RCU flavors, an RCU read-side critical section is entered
> > 	using rcu_read_lock(), anything that disables bottom halves,
> > 	anything that disables interrupts, or anything that disables
> > 	preemption.
> > 
> > 2.	If the access might be within an RCU read-side critical section
> > 	on the one hand, or protected by (say) my_lock on the other,
> > 	use rcu_dereference_check(), for example:
> > 	
> > 		p1 = rcu_dereference_check(p->rcu_protected_pointer,
> > 					   lockdep_is_held(&my_lock));
> > 
> > 
> > 3.	If the access might be within an RCU read-side critical section
> > 	on the one hand, or protected by either my_lock or your_lock on
> > 	the other, again use rcu_dereference_check(), for example:
> > 
> > 		p1 = rcu_dereference_check(p->rcu_protected_pointer,
> > 					   lockdep_is_held(&my_lock) ||
> > 					   lockdep_is_held(&your_lock));
> > 
> > 4.	If the access is on the update side, so that it is always protected
> > 	by my_lock, use rcu_dereference_protected():
> > 
> > 		p1 = rcu_dereference_protected(p->rcu_protected_pointer,
> > 					       lockdep_is_held(&my_lock));
> > 
> > 	This can be extended to handle multiple locks as in #3 above,
> > 	and both can be extended to check other conditions as well.
> > 
> > 5.	If the protection is supplied by the caller, and is thus unknown
> > 	to this code, that is when you use rcu_dereference_raw().  Or
> > 	I suppose you could use it when the lockdep expression would be
> > 	excessively complex, except that a better approach in that case
> > 	might be to take a long hard look at your synchronization design.
> > 	Still, there are data-locking cases where any one of a very
> > 	large number of locks or reference counters suffices to protect the
> > 	pointer, so rcu_derefernce_raw() does have its place.
> > 
> > 	However, its place is probably quite a bit smaller than one
> > 	might expect given the number of uses in the current kernel.
> > 	Ditto for its synonym, rcu_dereference_protected( ... , 1).  :-/
> 
> Is this documented anywhere (apart from here?)

In the docbook headers for these functions, apart from rcu_dereference_raw(),
whose use I am not encouraging.

But having it in one place with examples might be helpful.  Does the
patch at the end of this email seem reasonable?

> > Now on to this sparse checking and what the point of it is.  This sparse
> > checking is opt-in.  Its purpose is to catch cases where someone
> > mistakenly does something like:
> > 
> > 	p = q->rcu_protected_pointer;
> > 
> > When they should have done this instead:
> > 
> > 	p = rcu_dereference(q->rcu_protected_pointer);
> > 
> > If you wish to opt into this checking, you need to mark the pointer
> > definitions (in this case ->private) with __rcu.  It may also
> > be necessary to mark function parameters as well, as is done for
> > radix_tree_iter_resume().  If you do not wish to use this checking,
> > you should ignore these sparse warnings.
> > 
> > Unfortunately, I don't know of a way to inform 0-day test robot of
> > the various maintainers' opt-in/out choices.
> 
> Oh geeze.
> 
> Good luck, Suren ;)

Ummm...  OK...

							Thanx, Paul

------------------------------------------------------------------------

commit abf0d8830a2885af9d17c41cfb7fe32321df94cb
Author: Paul E. McKenney <paulmck@linux.ibm.com>
Date:   Tue Feb 12 07:51:24 2019 -0800

    doc: Describe choice of rcu_dereference() APIs and __rcu usage
    
    Reported-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Paul E. McKenney <paulmck@linux.ibm.com>

diff --git a/Documentation/RCU/rcu_dereference.txt b/Documentation/RCU/rcu_dereference.txt
index ab96227bad42..bf699e8cfc75 100644
--- a/Documentation/RCU/rcu_dereference.txt
+++ b/Documentation/RCU/rcu_dereference.txt
@@ -351,3 +351,106 @@ garbage values.
 
 In short, rcu_dereference() is -not- optional when you are going to
 dereference the resulting pointer.
+
+
+WHICH MEMBER OF THE rcu_dereference() FAMILY SHOULD YOU USE?
+
+First, please avoid using rcu_dereference_raw() and also please avoid
+using rcu_dereference_check() and rcu_dereference_protected() with a
+second argument with a constant value of 1 (or true, for that matter).
+With that caution out of the way, here is some guidance for which
+member of the rcu_dereference() to use in various situations:
+
+1.	If the access needs to be within an RCU read-side critical
+	section, use rcu_dereference().  With the new consolidated
+	RCU flavors, an RCU read-side critical section is entered
+	using rcu_read_lock(), anything that disables bottom halves,
+	anything that disables interrupts, or anything that disables
+	preemption.
+
+2.	If the access might be within an RCU read-side critical section
+	on the one hand, or protected by (say) my_lock on the other,
+	use rcu_dereference_check(), for example:
+
+		p1 = rcu_dereference_check(p->rcu_protected_pointer,
+					   lockdep_is_held(&my_lock));
+
+
+3.	If the access might be within an RCU read-side critical section
+	on the one hand, or protected by either my_lock or your_lock on
+	the other, again use rcu_dereference_check(), for example:
+
+		p1 = rcu_dereference_check(p->rcu_protected_pointer,
+					   lockdep_is_held(&my_lock) ||
+					   lockdep_is_held(&your_lock));
+
+4.	If the access is on the update side, so that it is always protected
+	by my_lock, use rcu_dereference_protected():
+
+		p1 = rcu_dereference_protected(p->rcu_protected_pointer,
+					       lockdep_is_held(&my_lock));
+
+	This can be extended to handle multiple locks as in #3 above,
+	and both can be extended to check other conditions as well.
+
+5.	If the protection is supplied by the caller, and is thus unknown
+	to this code, that is the rare case when rcu_dereference_raw()
+	is appropriate.  In addition, rcu_dereference_raw() might be
+	appropriate when the lockdep expression would be excessively
+	complex, except that a better approach in that case might be to
+	take a long hard look at your synchronization design.  Still,
+	there are data-locking cases where any one of a very large number
+	of locks or reference counters suffices to protect the pointer,
+	so rcu_dereference_raw() does have its place.
+
+	However, its place is probably quite a bit smaller than one
+	might expect given the number of uses in the current kernel.
+	Ditto for its synonym, rcu_dereference_check( ... , 1), and
+	its close relative, rcu_dereference_protected(... , 1).
+
+
+SPARSE CHECKING OF RCU-PROTECTED POINTERS
+
+The sparse static-analysis tool checks for direct access to RCU-protected
+pointers, which can result in "interesting" bugs due to compiler
+optimizations involving invented loads and perhaps also load tearing.
+For example, suppose someone mistakenly does something like this:
+
+	p = q->rcu_protected_pointer;
+	do_something_with(p->a);
+	do_something_else_with(p->b);
+
+If register pressure is high, the compiler might optimize "p" out
+of existence, transforming the code to something like this:
+
+	do_something_with(q->rcu_protected_pointer->a);
+	do_something_else_with(q->rcu_protected_pointer->b);
+
+This could fatally disappoint your code if q->rcu_protected_pointer
+changed in the meantime.  Nor is this a theoretical problem:  Exactly
+this sort of bug cost Paul E. McKenney (and several of his innocent
+colleagues) a three-day weekend back in the early 1990s.
+
+Load tearing could of course result in dereferencing a mashup of a pair
+of pointers, which also might fatally disappoint your code.
+
+These problems could have been avoided simply by making the code instead
+read as follows:
+
+	p = rcu_dereference(q->rcu_protected_pointer);
+	do_something_with(p->a);
+	do_something_else_with(p->b);
+
+Unfortunately, these sorts of bugs can be extremely hard to spot during
+review.  This is where the sparse tool comes into play, along with the
+"__rcu" marker.  If you mark a pointer declaration, whether in a structure
+or as a formal parameter, with "__rcu", which tells sparse to complain if
+this pointer is accessed directly.  It will also cause sparse to complain
+if a pointer not marked with "__rcu" is accessed using rcu_dereference()
+and friends.  For example, ->rcu_protected_pointer might be declared as
+follows:
+
+	struct foo __rcu *rcu_protected_pointer;
+
+Use of "__rcu" is opt-in.  If you choose not to use it, then you should
+ignore the sparse warnings.

