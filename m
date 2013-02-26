Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 7499D6B0005
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 06:39:04 -0500 (EST)
Received: by mail-oa0-f46.google.com with SMTP id k1so4882841oag.5
        for <linux-mm@kvack.org>; Tue, 26 Feb 2013 03:39:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <512C15F0.6030907@oracle.com>
References: <512B677D.1040501@oracle.com>
	<CAHGf_=rur29gFs9R9AYeDwnbVBm3b3cOfAn2xyi=mQ+ZbgzEDA@mail.gmail.com>
	<512C15F0.6030907@oracle.com>
Date: Tue, 26 Feb 2013 19:39:03 +0800
Message-ID: <CAJd=RBBxTutPsF+XPZGt44eT1f0uPAQfCvQj_UmwdDg82J=F+A@mail.gmail.com>
Subject: Re: mm: BUG in mempolicy's sp_insert
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>

On Tue, Feb 26, 2013 at 9:54 AM, Sasha Levin <sasha.levin@oracle.com> wrote:
> On 02/25/2013 08:52 PM, KOSAKI Motohiro wrote:
>> On Mon, Feb 25, 2013 at 8:30 AM, Sasha Levin <sasha.levin@oracle.com> wrote:
>>> Hi all,
>>>
>>> While fuzzing with trinity inside a KVM tools guest running latest -next kernel,
>>> I've stumbled on the following BUG:
>>>
>>> [13551.830090] ------------[ cut here ]------------
>>> [13551.830090] kernel BUG at mm/mempolicy.c:2187!
>>> [13551.830090] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>>
>> Unfortunately, I didn't reproduce this. I'll try it tonight.
>
> I've actually managed to reproduce it again since then, so it's not a one time
> fluke (which is a good sign a I guess).
>
> It did require about an hour of fuzzing just mm with trinity.
>
Insert new node after updating node in tree.

Hillf

--- a/mm/mempolicy.c	Tue Feb 26 19:33:20 2013
+++ b/mm/mempolicy.c	Tue Feb 26 19:35:38 2013
@@ -2391,8 +2391,8 @@ restart:
 				*mpol_new = *n->policy;
 				atomic_set(&mpol_new->refcnt, 1);
 				sp_node_init(n_new, n->end, end, mpol_new);
-				sp_insert(sp, n_new);
 				n->end = start;
+				sp_insert(sp, n_new);
 				n_new = NULL;
 				mpol_new = NULL;
 				break;
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
