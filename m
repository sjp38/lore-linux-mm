Return-Path: <SRS0=K2Kt=QQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41E17C282C4
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 07:44:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDEE120857
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 07:44:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDEE120857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A5AF8E00AB; Sat,  9 Feb 2019 02:44:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1844E8E00A9; Sat,  9 Feb 2019 02:44:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 069948E00AB; Sat,  9 Feb 2019 02:44:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB6F88E00A9
	for <linux-mm@kvack.org>; Sat,  9 Feb 2019 02:44:15 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id o7so4555167pfi.23
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 23:44:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=rFFtFbHA2bUBfC4GGV168dp5tfJ2NyImgCF0m/C/A7A=;
        b=Om1NquRkWo9XL5Zs8liGgo0gh0mEow8bcQBNi2bRvyWfkYi8pHh8egTYKNuPcEfS6d
         RptL+mm4Wd6/T7Etnb0+kEj6SjObZzPtNM3XvVzXYpvR83zEaDTTcGpkisiEkX3E8VQy
         xpF/J4t5YXGQdSGb16nzvgtJezYFqd2gNVbXfh38/Lu/n3y7/RTVDy7MqLBaxGJpfYYI
         MT2Te07EKA1f2eOLcEflZiXxych1GQDor2XJF+9NafqAv+AyXg82Iu+1IP7WSDH+8a1X
         SMuM6bMI5stgwlaUG9Oz7OXvdJu7CSiRilO3iw1BdXN+nHCBOIAgm8D/4ngmmWxZARfS
         3l2w==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZ2fOynoEeyMdIRqCfR/sBZBvkJRuMIUK7tK5PuVlnw8vkdFXhC
	EN0CsAt+HZUlrsUiKX+IitFV/te0zknwLTa45N/1lHOGE99y7blhyJJFDzJAVZ6Ufu59NawDclc
	UPEvosp9UAo9teqc6YmDTCECUYiesLlgT4nf/tP/rhW4IWCMGpAyQkB7/WEISV8s=
X-Received: by 2002:a63:a80c:: with SMTP id o12mr6890879pgf.185.1549698255205;
        Fri, 08 Feb 2019 23:44:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbDPrewRRXWxx2ly3YEhG5v031H1HqtuuEC0pqL+cQ+VTBFTFDsNwnAeHwPmfrzhsxeaGQB
X-Received: by 2002:a63:a80c:: with SMTP id o12mr6890834pgf.185.1549698254210;
        Fri, 08 Feb 2019 23:44:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549698254; cv=none;
        d=google.com; s=arc-20160816;
        b=n/9tRMPOBx2qY9Ynm+ZPB+yg9o5eIFTsjVeBWou9DWqplTTsQf78wTR9pxuDD/impY
         oGj36Q3Hij7Z5JmJUhje6L7eq/v2DIaw9grbprHHIZ05u/cIj+3aahS4VxblI8dqtKyC
         rxKH3Ty99xpnJLA7IW8JvLvtCKDO6Z3sd22/QcOBC1TQTrO063S/UrdX/y9fY0+6ftyP
         yfh0UyStrBxQT6jyVb7Dwf0AS7hbAco9nEs6Su4BSycKQw5TlAz3i9VPchMh+dKi5c0q
         eA9N6qAikiqPR68vxOM0vW+hveED1q57NoODsPAjiIfotd3RuMM56QjHuMnTpHBznsNm
         yYYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=rFFtFbHA2bUBfC4GGV168dp5tfJ2NyImgCF0m/C/A7A=;
        b=u9BN/6UGS/pR9TFW63BeDzUQTjm8r95ohOuUUgWjztu/b6ubmcdlHRzP1xD7HySN7U
         Syuf4gC+UE1YCPDkN3WhdZs9S2twz6C9hx/F1MWR9HfX9Ky9Z3XLZDvmCM4Lq6CjJi/H
         mvuvE+/wzK884G3Xb8vsu4X6tWvwjSb/DPrnaubcQ7LDUa7/o1BSD2yuy3dNOLPR8Yq8
         jKzO+a7If2aiK9AoznSb8A6H0vBy4/WEfd3zM3ZQgFDXp17YVzBKUBtdLxMDVbnkMPE/
         3QDn8Fe1SNqouEJ7lNejH49kcGI3R/z1neuCoDxSCZEhJMAE6SLTVIs/LFzrWhSUqZ9y
         Iy6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o3si2360207pls.265.2019.02.08.23.44.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 23:44:14 -0800 (PST)
Received-SPF: neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of paulmck@linux.vnet.ibm.com) smtp.mailfrom=paulmck@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x197hl70035477
	for <linux-mm@kvack.org>; Sat, 9 Feb 2019 02:44:13 -0500
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qhsg6ay5y-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 09 Feb 2019 02:44:13 -0500
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 9 Feb 2019 07:44:12 -0000
Received: from b01cxnp22033.gho.pok.ibm.com (9.57.198.23)
	by e17.ny.us.ibm.com (146.89.104.204) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sat, 9 Feb 2019 07:44:08 -0000
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x197i7Mr25362556
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sat, 9 Feb 2019 07:44:07 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 83646B2064;
	Sat,  9 Feb 2019 07:44:07 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2E2C8B2065;
	Sat,  9 Feb 2019 07:44:07 +0000 (GMT)
Received: from paulmck-ThinkPad-W541 (unknown [9.80.232.171])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Sat,  9 Feb 2019 07:44:07 +0000 (GMT)
Received: by paulmck-ThinkPad-W541 (Postfix, from userid 1000)
	id 4BEDB16C379A; Fri,  8 Feb 2019 23:44:07 -0800 (PST)
Date: Fri, 8 Feb 2019 23:44:07 -0800
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190208151441.4048e6968579dd178b259609@linux-foundation.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-TM-AS-GCONF: 00
x-cbid: 19020907-0040-0000-0000-000004BF0FD4
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010563; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000279; SDB=6.01158450; UDB=6.00604226; IPR=6.00938985;
 MB=3.00025502; MTD=3.00000008; XFM=3.00000015; UTC=2019-02-09 07:44:10
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19020907-0041-0000-0000-000008CA2CB8
Message-Id: <20190209074407.GE4240@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-09_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902090057
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 08, 2019 at 03:14:41PM -0800, Andrew Morton wrote:
> On Fri, 8 Feb 2019 02:29:33 +0800 kbuild test robot <lkp@intel.com> wrote:
> 
> > tree:   https://urldefense.proofpoint.com/v2/url?u=https-3A__git.kernel.org_pub_scm_linux_kernel_git_next_linux-2Dnext.git&d=DwICAg&c=jf_iaSHvJObTbx-siA1ZOg&r=q4hkQkeaNH3IlTsPvEwkaUALMqf7y6jCMwT5b6lVQbQ&m=myIJaLgovNwHx7SqCW_p1sQx2YvRlmVbShFnuZEFqxY&s=0Y32d-tVCGOq6Vu_VAGgVgbEplhfvOSJ5evHbXTtyBI&e= master
> > head:   1bd831d68d5521c01d783af0275439ac645f5027
> > commit: e7acbba0d6f7a24c8d24280089030eb9a0eb7522 [6618/6917] psi: introduce psi monitor
> > reproduce:
> >         # apt-get install sparse
> >         git checkout e7acbba0d6f7a24c8d24280089030eb9a0eb7522
> >         make ARCH=x86_64 allmodconfig
> >         make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'
> > 
> > All errors (new ones prefixed by >>):
> > 
> >    kernel/sched/psi.c:151:6: sparse: warning: symbol 'psi_enable' was not declared. Should it be static?
> > >> kernel/sched/psi.c:1230:13: sparse: error: incompatible types in comparison expression (different address spaces)
> >    kernel/sched/psi.c:774:30: sparse: warning: dereference of noderef expression
> > 
> > vim +1230 kernel/sched/psi.c
> > 
> >   1222	
> >   1223	static __poll_t psi_fop_poll(struct file *file, poll_table *wait)
> >   1224	{
> >   1225		struct seq_file *seq = file->private_data;
> >   1226		struct psi_trigger *t;
> >   1227		__poll_t ret;
> >   1228	
> >   1229		rcu_read_lock();
> > > 1230		t = rcu_dereference(seq->private);
> >   1231		if (t)
> >   1232			ret = psi_trigger_poll(t, file, wait);
> >   1233		else
> >   1234			ret = DEFAULT_POLLMASK | EPOLLERR | EPOLLPRI;
> >   1235		rcu_read_unlock();
> >   1236	
> >   1237		return ret;
> >   1238	
> 
> Well a bit of googling led me to this fix:
> 
> --- a/kernel/sched/psi.c~psi-introduce-psi-monitor-fix-fix
> +++ a/kernel/sched/psi.c
> @@ -1227,7 +1227,7 @@ static __poll_t psi_fop_poll(struct file
>  	__poll_t ret;
>  
>  	rcu_read_lock();
> -	t = rcu_dereference(seq->private);
> +	t = rcu_dereference_raw(seq->private);
>  	if (t)
>  		ret = psi_trigger_poll(t, file, wait);
>  	else
> 
> But I have no idea why this works, nor what's going on in there. 
> rcu_dereference_raw() documentation is scant.
> 
> Paul, can you please shed light?

First, please avoid using rcu_dereference_raw() where possible.  It is
intended for situations where the developer cannot easily state what
is to be protecting access to an RCU-protected data structure.  So...

1.	If the access needs to be within an RCU read-side critical
	section, use rcu_dereference().  With the new consolidated
	RCU flavors, an RCU read-side critical section is entered
	using rcu_read_lock(), anything that disables bottom halves,
	anything that disables interrupts, or anything that disables
	preemption.

2.	If the access might be within an RCU read-side critical section
	on the one hand, or protected by (say) my_lock on the other,
	use rcu_dereference_check(), for example:
	
		p1 = rcu_dereference_check(p->rcu_protected_pointer,
					   lockdep_is_held(&my_lock));


3.	If the access might be within an RCU read-side critical section
	on the one hand, or protected by either my_lock or your_lock on
	the other, again use rcu_dereference_check(), for example:

		p1 = rcu_dereference_check(p->rcu_protected_pointer,
					   lockdep_is_held(&my_lock) ||
					   lockdep_is_held(&your_lock));

4.	If the access is on the update side, so that it is always protected
	by my_lock, use rcu_dereference_protected():

		p1 = rcu_dereference_protected(p->rcu_protected_pointer,
					       lockdep_is_held(&my_lock));

	This can be extended to handle multiple locks as in #3 above,
	and both can be extended to check other conditions as well.

5.	If the protection is supplied by the caller, and is thus unknown
	to this code, that is when you use rcu_dereference_raw().  Or
	I suppose you could use it when the lockdep expression would be
	excessively complex, except that a better approach in that case
	might be to take a long hard look at your synchronization design.
	Still, there are data-locking cases where any one of a very
	large number of locks or reference counters suffices to protect the
	pointer, so rcu_derefernce_raw() does have its place.

	However, its place is probably quite a bit smaller than one
	might expect given the number of uses in the current kernel.
	Ditto for its synonym, rcu_dereference_protected( ... , 1).  :-/

Now on to this sparse checking and what the point of it is.  This sparse
checking is opt-in.  Its purpose is to catch cases where someone
mistakenly does something like:

	p = q->rcu_protected_pointer;

When they should have done this instead:

	p = rcu_dereference(q->rcu_protected_pointer);

If you wish to opt into this checking, you need to mark the pointer
definitions (in this case ->private) with __rcu.  It may also
be necessary to mark function parameters as well, as is done for
radix_tree_iter_resume().  If you do not wish to use this checking,
you should ignore these sparse warnings.

Unfortunately, I don't know of a way to inform 0-day test robot of
the various maintainers' opt-in/out choices.

							Thanx, Paul

