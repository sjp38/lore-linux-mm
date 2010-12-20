Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DB84B6B008A
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 17:14:19 -0500 (EST)
Date: Mon, 20 Dec 2010 23:05:25 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [updated PATCH] Close mem leak in error path in
 mm/hugetlb.c::nr_hugepages_store_common()
In-Reply-To: <AANLkTikNx5SG9Z=tUu6tyFRqnR2sLe5NxAjLCJr1UKmq@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.1012202302460.23785@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1012192305260.6486@swampdragon.chaosbits.net> <AANLkTikNx5SG9Z=tUu6tyFRqnR2sLe5NxAjLCJr1UKmq@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-245131414-1292882725=:23785"
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-245131414-1292882725=:23785
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 20 Dec 2010, Minchan Kim wrote:

> On Mon, Dec 20, 2010 at 7:10 AM, Jesper Juhl <jj@chaosbits.net> wrote:
> > Hi,
> >
> > The NODEMASK_ALLOC macro dynamically allocates memory for its second
> > argument ('nodes_allowed' in this context).
> > In nr_hugepages_store_common() we may abort early if strict_strtoul()
> > fails, but in that case we do not free the memory already allocated to
> > 'nodes_allowed', causing a memory leak.
> > This patch closes the leak by freeing the memory in the error path.
> >
> >
> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> > ---
> >  hugetlb.c |    4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> >
> >  compile tested only
> >
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 8585524..9fdcc35 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1439,8 +1439,10 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
> >        NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
> >
> >        err = strict_strtoul(buf, 10, &count);
> > -       if (err)
> > +       if (err) {
> > +               kfree(nodes_allowed);
> 
> Nice catch. But use NODEMASK_FREE. It might be not kmalloced object.
> 
Right. I just checked the macro and it used kmalloc(), so I just wrote 
kfree. But you are right, NODEMASK_FREE is the right thing to use here. 
Updated patch below.


Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 hugetlb.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8585524..71e7886 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1439,8 +1439,10 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
 	NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
 
 	err = strict_strtoul(buf, 10, &count);
-	if (err)
+	if (err) {
+		NODEMASK_FREE(nodes_allowed);
 		return 0;
+	}
 
 	h = kobj_to_hstate(kobj, &nid);
 	if (nid == NUMA_NO_NODE) {



-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

--8323328-245131414-1292882725=:23785--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
