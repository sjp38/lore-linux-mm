Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D97A7C10F00
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 08:20:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E30B20661
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 08:20:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E30B20661
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD0B28E0003; Wed,  6 Mar 2019 03:20:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A801D8E0001; Wed,  6 Mar 2019 03:20:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FA5E8E0003; Wed,  6 Mar 2019 03:20:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 360CC8E0001
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 03:20:20 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id k32so5796537edc.23
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 00:20:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=+VeugAbh1zJYqOxJTDXrgSamYRr48hqpOhTQKNmUpoU=;
        b=M5z7pOVtg3a/bC19r++D74K5dtxDtZPAa+Q+xDeJKGERglGqwZiYmwG7PYMPVDu/Ml
         WY6AVw8r1bqt5do49Fl2/ezfPQmfji6cHy0lFGlvwt0y4UQMQPUD0+R61J06OQunim2S
         19+z+SUf3pun1kp8V/H22OlnVFRfue+3fd4s8TrmEjeIcA+kEkbfzEjojqjZq4qMmaam
         tJZxp9ud3CKrW6dJs+2qOGi/EOGmYmRwMc/t9J9jHeb4+fQpbUpiga9kBv7rWdiARj53
         gAy0bIFNpg3iwJRF81BcIirW9kHMo4ltlqAsx8odKc5Klb9r9pTm1aW/ops76oRZifZw
         21+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWzN8oBtvZ9MinqXKHpP731OV2v7ecxz2+ebEnp7pGuROtb+ZH4
	sPBQB4jCdgp1ajcjEk6UByskEgasI6IthxN6jsEuwCKAYfm2LkTYh1Hz6zpQODzWN4gMPwEQKOy
	JoSyEIZ7qS/eKivApe/JPbL7BJSYabi82LIVfGUSLo+ZVI59IhxxAP8UufF5wgka77w==
X-Received: by 2002:a50:ac6d:: with SMTP id w42mr23044800edc.122.1551860419732;
        Wed, 06 Mar 2019 00:20:19 -0800 (PST)
X-Google-Smtp-Source: APXvYqz+ygPa34hqUCNDXfqzHWG7ZkFo1JqbP44HBKhVptOFAUuSaaAWGXCXllo6Dpl7Cc4WP80M
X-Received: by 2002:a50:ac6d:: with SMTP id w42mr23044757edc.122.1551860418804;
        Wed, 06 Mar 2019 00:20:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551860418; cv=none;
        d=google.com; s=arc-20160816;
        b=RnKfedMRcegenRnHFD4t1AFMAGKxJxBs272HEoF1EDrkipkSbA5yoOJkl7ATukA7Cc
         KQdVXeUtjW8lK2J/ohsEDxeG/CbQJ8fk+jwC5NylUWTHwtswpYTKlrIy2FT36/JOzU+T
         HnH+WpZ95wOB3+zs8HnFa9sEYSmcTAcW02NbL6SOhG+aZtoQIt0RQobLpNJJsTmU8n0A
         UDgON5WoDW5kaHhANnj/195qAPvRZmlcfUg8rnINFy/2ufl7NgPqLHfPINykbDOF88A4
         H3yFGLJfUz4ussdwtOxPDOGNRS0V3N1DZnTxZVD334yBTDal8T/ksp3DsE8Oo7sy2aJP
         o/VA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=+VeugAbh1zJYqOxJTDXrgSamYRr48hqpOhTQKNmUpoU=;
        b=vDfdCfYsnukQKm3aNPOSA6/t2lUWtT940Nrl5L1Q+DpXvZa5nFYLgEItF8H1C9oz8G
         CkN5SPWZ0sTGVJk+AC1cHRuSMAe3J+QVAyFZTPYNKhLyig4RlNSAE6naIYRdeofyEEcV
         2L8aFn6kjRKO/xy6Xy7DSZwWzO5dSyq8cN55WJIh+T2Vvs1y7lPZqrE4o2Qbks2HMF0J
         4am8GMQdwhtcMpsO3do2g+5WD4NT+2RkHnuxIHC01trqL2KAa7I9ERYCgdU/JEIUx58C
         ClmLNCTwl17VmFMIGSC5g84JZn/WIYPnKz+gSuh2C9iLVw3aWUuenjtpgkWHOwCoQIL4
         OhNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l57si356582edb.109.2019.03.06.00.20.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 00:20:18 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x268DYnQ088381
	for <linux-mm@kvack.org>; Wed, 6 Mar 2019 03:20:17 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2r29pab9vd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 06 Mar 2019 03:20:17 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 6 Mar 2019 08:20:15 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 6 Mar 2019 08:20:11 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x268KALT33357846
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 6 Mar 2019 08:20:10 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4602511C058;
	Wed,  6 Mar 2019 08:20:10 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id F0AC611C054;
	Wed,  6 Mar 2019 08:20:08 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  6 Mar 2019 08:20:08 +0000 (GMT)
Date: Wed, 6 Mar 2019 10:20:07 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>,
        syzbot <syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com>,
        Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org,
        Johannes Weiner <hannes@cmpxchg.org>,
        LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>,
        David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>,
        Matthew Wilcox <willy@infradead.org>, Mel Gorman <mgorman@suse.de>,
        Vlastimil Babka <vbabka@suse.cz>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Peter Xu <peterx@redhat.com>
Subject: Re: KASAN: use-after-free Read in get_mem_cgroup_from_mm
References: <CACT4Y+Z+CH0UTdSz-w_woMPrBwg-GuobV1Su4qd9ReffTkyfVg@mail.gmail.com>
 <5C7D2F82.40907@huawei.com>
 <CACT4Y+agwaszODNGJHCqn4fSk4Le9exn3Cau0nornJ0RaTpDJw@mail.gmail.com>
 <5C7D4500.3070607@huawei.com>
 <CACT4Y+b6y_3gTpR8LvNREHOV0TP7jB=Zp1L03dzpaz_SaeESng@mail.gmail.com>
 <5C7E1A38.2060906@huawei.com>
 <20190306020540.GA23850@redhat.com>
 <5C7F6048.2050802@huawei.com>
 <20190306062625.GA3549@rapoport-lnx>
 <5C7F7992.7050806@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5C7F7992.7050806@huawei.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19030608-0016-0000-0000-0000025E6846
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19030608-0017-0000-0000-000032B8EEDC
Message-Id: <20190306082006.GB3549@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-06_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903060057
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 03:41:06PM +0800, zhong jiang wrote:
> On 2019/3/6 14:26, Mike Rapoport wrote:
> > Hi,
> >
> > On Wed, Mar 06, 2019 at 01:53:12PM +0800, zhong jiang wrote:
> >> On 2019/3/6 10:05, Andrea Arcangeli wrote:
> >>> Hello everyone,
> >>>
> >>> [ CC'ed Mike and Peter ]
> >>>
> >>> On Tue, Mar 05, 2019 at 02:42:00PM +0800, zhong jiang wrote:
> >>>> On 2019/3/5 14:26, Dmitry Vyukov wrote:
> >>>>> On Mon, Mar 4, 2019 at 4:32 PM zhong jiang <zhongjiang@huawei.com> wrote:
> >>>>>> On 2019/3/4 22:11, Dmitry Vyukov wrote:
> >>>>>>> On Mon, Mar 4, 2019 at 3:00 PM zhong jiang <zhongjiang@huawei.com> wrote:
> >>>>>>>> On 2019/3/4 15:40, Dmitry Vyukov wrote:
> >>>>>>>>> On Sun, Mar 3, 2019 at 5:19 PM zhong jiang <zhongjiang@huawei.com> wrote:
> >>>>>>>>>> Hi, guys
> >>>>>>>>>>
> >>>>>>>>>> I also hit the following issue. but it fails to reproduce the issue by the log.
> >>>>>>>>>>
> >>>>>>>>>> it seems to the case that we access the mm->owner and deference it will result in the UAF.
> >>>>>>>>>> But it should not be possible that we specify the incomplete process to be the mm->owner.
> >>>>>>>>>>
> >>>>>>>>>> Any thoughts?
> >>>>>>>>> FWIW syzbot was able to reproduce this with this reproducer.
> >>>>>>>>> This looks like a very subtle race (threaded reproducer that runs
> >>>>>>>>> repeatedly in multiple processes), so most likely we are looking for
> >>>>>>>>> something like few instructions inconsistency window.
> >>>>>>>>>
> >>>>>>>> I has a little doubtful about the instrustions inconsistency window.
> >>>>>>>>
> >>>>>>>> I guess that you mean some smb barriers should be taken into account.:-)
> >>>>>>>>
> >>>>>>>> Because IMO, It should not be the lock case to result in the issue.
> >>>>>>> Since the crash was triggered on x86 _most likley_ this is not a
> >>>>>>> missed barrier. What I meant is that one thread needs to executed some
> >>>>>>> code, while another thread is stopped within few instructions.
> >>>>>>>
> >>>>>>>
> >>>>>> It is weird and I can not find any relationship you had said with the issue.:-(
> >>>>>>
> >>>>>> Because It is the cause that mm->owner has been freed, whereas we still deference it.
> >>>>>>
> >>>>>> From the lastest freed task call trace, It fails to create process.
> >>>>>>
> >>>>>> Am I miss something or I misunderstand your meaning. Please correct me.
> >>>>> Your analysis looks correct. I am just saying that the root cause of
> >>>>> this use-after-free seems to be a race condition.
> >>>>>
> >>>>>
> >>>>>
> >>>> Yep, Indeed,  I can not figure out how the race works. I will dig up further.
> >>> Yes it's a race condition.
> >>>
> >>> We were aware about the non-cooperative fork userfaultfd feature
> >>> creating userfaultfd file descriptor that gets reported to the parent
> >>> uffd, despite they belong to mm created by failed forks.
> >>>
> >>> https://www.spinics.net/lists/linux-mm/msg136357.html
> >>>
> >> Hi, Andrea
> >>
> >> I still not clear why uffd ioctl can use the incomplete process as the mm->owner.
> >> and how to produce the race.
> > There is a C reproducer in  the syzcaller report:
> >
> > https://syzkaller.appspot.com/x/repro.c?x=172fa5a3400000
> >  
> >> From your above explainations,   My underdtanding is that the process handling do_exexve
> >> will have a temporary mm,  which will be used by the UUFD ioctl.
> > The race is between userfaultfd operation and fork() failure:
> >
> > forking thread                  | userfaultfd monitor thread
> > --------------------------------+-------------------------------
> > fork()                          |
> >   dup_mmap()                    |
> >     dup_userfaultfd()           |
> >     dup_userfaultfd_complete()  |
> >                                 |  read(UFFD_EVENT_FORK)
> >                                 |  uffdio_copy()
> >                                 |    mmget_not_zero()
> >     goto bad_fork_something     |
> >     ...                         |
> > bad_fork_free:                  |
> >       free_task()               |
> >                                 |  mem_cgroup_from_task()
> >                                 |       /* access stale mm->owner */
> >  
> Hi, Mike
> 
> forking thread fails to create the process ,and then free the allocated task struct.
> Other userfaultfd monitor thread should not access the stale mm->owner.
> 
> The parent process and child process do not share the mm struct.  Userfaultfd monitor thread's
> mm->owner should not point to the freed child task_struct.

Userfaultfd can monitor remote mm's [1]. In this case, dup_userfaultfd() and
dup_userfaultfd_complete() create uffd context for the new process and
notify userspace uffd monitor about this new context. The uffd monitor then
can perform uffd operations on the new context.

On the right side the mmget_not_zero() will take the reference for the mm of the newly
created process.

[1] https://www.kernel.org/doc/html/latest/admin-guide/mm/userfaultfd.html#non-cooperative-userfaultfd
 
> and due to the existence of tasklist_lock,  we can not specify the mm->owner to freed task_struct.
> 
> I miss something,=-O
> 
> Thanks,
> zhong jiang
> >> Thanks,
> >> zhong jiang
> 
> 

-- 
Sincerely yours,
Mike.

