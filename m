Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0795960021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 15:47:37 -0500 (EST)
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id nB9KlV73016055
	for <linux-mm@kvack.org>; Wed, 9 Dec 2009 20:47:31 GMT
Received: from pzk14 (pzk14.prod.google.com [10.243.19.142])
	by spaceape13.eur.corp.google.com with ESMTP id nB9KlRe5013893
	for <linux-mm@kvack.org>; Wed, 9 Dec 2009 12:47:28 -0800
Received: by pzk14 with SMTP id 14so5773198pzk.23
        for <linux-mm@kvack.org>; Wed, 09 Dec 2009 12:47:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091208211639.8499FB151F@basil.firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
	 <20091208211639.8499FB151F@basil.firstfloor.org>
Date: Wed, 9 Dec 2009 12:47:27 -0800
Message-ID: <6599ad830912091247v1270a86er45ea8ceeff28e727@mail.gmail.com>
Subject: Re: [PATCH] [23/31] HWPOISON: add memory cgroup filter
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@jp.fujitsu.com, hugh.dickins@tiscali.co.uk, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, lizf@cn.fujitsu.com, npiggin@suse.de, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Dec 8, 2009 at 1:16 PM, Andi Kleen <andi@firstfloor.org> wrote:
>
> The hwpoison test suite need to inject hwpoison to a collection of
> selected task pages, and must not touch pages not owned by them and
> thus kill important system processes such as init. (But it's OK to
> mis-hwpoison free/unowned pages as well as shared clean pages.
> Mis-hwpoison of shared dirty pages will kill all tasks, so the test
> suite will target all or non of such tasks in the first place.)

While the functionality sounds useful, the interface (passing an inode
number) feels a bit ugly to me. Also, if that group is deleted and a
new cgroup created, you could end up reusing the inode number.

How about an approach where you write either the cgroup path (relative
to the memcg mount) or an fd open on the desired cgroup? Then you
could store a (counted) css reference rather than an inode number,
which would make the filter function cleaner too, since it would just
need to compare css objects.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
