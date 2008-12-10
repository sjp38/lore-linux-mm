Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id mBAIQU4x006606
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 10:26:31 -0800
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id mBAJ0b2J027686
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 11:00:38 -0800
Received: from qyk13 (qyk13.prod.google.com [10.241.83.141])
	by spaceape7.eur.corp.google.com with ESMTP id mBAJ0Zgr002310
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 11:00:36 -0800
Received: by qyk13 with SMTP id 13so1659602qyk.1
        for <linux-mm@kvack.org>; Wed, 10 Dec 2008 11:00:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <6599ad830812101035v33dbc6cfh57aa5510f6d65d54@mail.gmail.com>
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
	 <20081209200647.a1fa76a9.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830812100240g5e549a5cqe29cbea736788865@mail.gmail.com>
	 <29741.10.75.179.61.1228908581.squirrel@webmail-b.css.fujitsu.com>
	 <6599ad830812101035v33dbc6cfh57aa5510f6d65d54@mail.gmail.com>
Date: Wed, 10 Dec 2008 11:00:35 -0800
Message-ID: <6599ad830812101100v4dc7f124jded0d767b92e541a@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/6] memcg: fix pre_destory handler
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 10, 2008 at 10:35 AM, Paul Menage <menage@google.com> wrote:
> On Wed, Dec 10, 2008 at 3:29 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>> (BTW, I don't like hierarchy-walk-by-small-locks approarch now because
>>  I'd like to implement scan-and-stop-continue routine.
>>  See how readdir() aginst /proc scans PID. It's very roboust against
>>  very temporal PIDs.)
>
> So you mean that you want to be able to sleep, and then contine
> approximately where you left off, without keeping any kind of
> reference count on the last cgroup that you touched? OK, so in that
> case rg id <S1175749AbYLJUrh>;
	Wed, 10 Dec 2008 15:47:37 -0500
Received: from mail143.messagelabs.com ([216.82.254.35]:29128 "EHLO
	mail143.messagelabs.com") by kvack.org with ESMTP
	id <S1175746AbYLJUr2>; Wed, 10 Dec 2008 15:47:28 -0500
X-VirusChecked:	Checked
X-Env-Sender: menage@google.com
X-Msg-Ref: server-13.tower-143.messagelabs.com!1228935641!66420628!1
X-StarScan-Version: 6.0.0; banners=-,-,-
X-Originating-IP: [216.239.45.13]
X-SpamReason: No, hits=0.3 required=7.0 tests=RCVD_BY_IP
Received: (qmail 21195 invoked from network); 10 Dec 2008 19:00:41 -0000
Received: from smtp-out.google.com (HELO smtp-out.google.com) (216.239.45.13)
  by server-13.tower-143.messagelabs.com with AES256-SHA encrypted SMTP; 10 Dec 2008 19:00:41 -0000
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id mBAJ0b2J027686
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 11:00:38 -0800
DKIM-Signature:	v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1228935640; bh=ASZ5/oA9ISwaQsIocrWoHpe+trA=;
	h=DomainKey-Signature:MIME-Version:In-Reply-To:References:Date:
	 Message-ID:Subject:From:To:Cc:Content-Type:
	 Content-Transfer-Encoding; b=YaIe4+BnL5b7jMXJQi6mAE1H4sLxfxvd2EQw3
	KGsdRqb2YTXY1wJQcXjjhDwDyo7fF+0syy6bYMLvtWBA4DVdg==
DomainKey-Signature: a=rsa-sha1; s=beta; d=google.com; c=nofws; q=dns;
	h=mime-version:in-reply-to:references:date:message-id:subject:from:to:
	cc:content-type:content-transfer-encoding;
	b=K6dc6Eb3ROdV/+GHbWN1bByx4bnYsijzkoIZGhtEfievBihLKEp0y96Iq4UE7JH/l
	dMwKPS+Y+LXafz4cFjlkw==
Received: from qyk13 (qyk13.prod.google.com [10.241.83.141])
	by spaceape7.eur.corp.google.com with ESMTP id mBAJ0Zgr002310
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 11:00:36 -0800
Received: by qyk13 with SMTP id 13so1659602qyk.1
        for <linux-mm@kvack.org>; Wed, 10 Dec 2008 11:00:35 -0800 (PST)
MIME-Version: 1.0
Received: by 10.215.41.10 with SMTP id t10mr2538002qaj.6.1228935635286; Wed, 
	10 Dec 2008 11:00:35 -0800 (PST)
In-Reply-To: <6599ad830812101035v33dbc6cfh57aa5510f6d65d54@mail.gmail.com>
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
	 <20081209200647.a1fa76a9.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830812100240g5e549a5cqe29cbea736788865@mail.gmail.com>
	 <29741.10.75.179.61.1228908581.squirrel@webmail-b.css.fujitsu.com>
	 <6599ad830812101035v33dbc6cfh57aa5510f6d65d54@mail.gmail.com>
Date:	Wed, 10 Dec 2008 11:00:35 -0800
Message-ID: <6599ad830812101100v4dc7f124jded0d767b92e541a@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/6] memcg: fix pre_destory handler
From:	Paul Menage <menage@google.com>
To:	KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc:	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>,
	"nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>,
	"lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>,
	"kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.1.5
Sender:	owner-linux-mm@kvack.org
Precedence: bulk
X-Loop:	owner-majordomo@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
X-Envelope-To: <"|/home/majordomo/wrapper archive -f /home/ftp/pub/archives/linux-mm/linux-mm -m -a"> (uid 0)
X-Orcpt: rfc822;linux-mm-outgoing
Original-Recipient: rfc822;linux-mm-outgoing

On Wed, Dec 10, 2008 at 10:35 AM, Paul Menage <menage@google.com> wrote:
> On Wed, Dec 10, 2008 at 3:29 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>> (BTW, I don't like hierarchy-walk-by-small-locks approarch now because
>>  I'd like to implement scan-and-stop-continue routine.
>>  See how readdir() aginst /proc scans PID. It's very roboust against
>>  very temporal PIDs.)
>
> So you mean that you want to be able to sleep, and then contine
> approximately where you left off, without keeping any kind of
> reference count on the last cgroup that you touched? OK, so in that
> case wrapping negative (inefficient) when the other end unmapped.

The only impact on x86 would have been that setting a mandatory lock on
a file which has at some time been opened O_RDWR and mapped MAP_SHARED
(but not necessarily PROT_WRITE) across a fork, might fail with -EAGAIN
when it should succeed, or succeed when it should fail.

But those architectures which rely on flush_dcache_page() to flush
userspace modifications back into the page before the kernel reads it,
may in some cases have skipped the flush after such a fork - though any
repetitive test will soon wrap the count negative, in which case it will
flush_dcache_page() unnecessarily.

Fix would be a two-liner, but mapping variable added, and comment moved.

Reported-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 kernel/fork.c |   15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

--- 2.6.28-rc7/kernel/fork.c	2008-11-15 23:09:30.000000000 +0000
+++ linux/kernel/fork.c	2008-12-10 12:49:13.000000000 +0000
@@ -315,17 +315,20 @@ static int dup_mmap(struct mm_struct *mm
 		file = tmp->vm_file;
 		if (file) {
 			struct inode *inode = file->f_path.dentry->d_inode;
+			struct address_space *mapping = file->f_mapping;
+
 			get_file(file);
 			if (tmp->vm_flags & VM_DENYWRITE)
 				atomic_dec(&inode->i_writecount);
-
-			/* insert tmp into the share list, just after mpnt */
-			spin_lock(&file->f_mapping->i_mmap_lock);
+			spin_lock(&mapping->i_mmap_lock);
+			if (tmp->vm_flags & VM_SHARED)
+				mapping->i_mmap_writable++;
 			tmp->vm_truncate_count = mpnt->vm_truncate_count;
-			flush_dcache_mmap_lock(file->f_mapping);
+			flush_dcache_mmap_lock(mapping);
+			/* insert tmp into the share list, just after mpnt */
 			vma_prio_tree_add(tmp, mpnt);
-			flush_dcache_mmap_unlock(file->f_mapping);
-			spin_unlock(&file->f_mapping->i_mmap_lock);
+			flush_dcache_mmap_unlock(mapping);
+			spin_unlock(&mapping->i_mmap_lock);
 		}
 
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
