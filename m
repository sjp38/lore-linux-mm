Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 67E186B0037
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 06:03:35 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id a1so5472660wgh.16
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 03:03:34 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id el6si5996790wid.33.2014.01.27.03.03.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Jan 2014 03:03:34 -0800 (PST)
Date: Mon, 27 Jan 2014 11:03:30 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch for-3.14] mm, mempolicy: fix mempolicy printing in
 numa_maps
Message-ID: <20140127110330.GH4963@suse.de>
References: <alpine.DEB.2.02.1401251902180.3140@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401251902180.3140@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Jan 25, 2014 at 07:12:35PM -0800, David Rientjes wrote:
> As a result of commit 5606e3877ad8 ("mm: numa: Migrate on reference 
> policy"), /proc/<pid>/numa_maps prints the mempolicy for any <pid> as 
> "prefer:N" for the local node, N, of the process reading the file.
> 
> This should only be printed when the mempolicy of <pid> is MPOL_PREFERRED 
> for node N.
> 
> If the process is actually only using the default mempolicy for local node 
> allocation, make sure "default" is printed as expected.
> 
> Reported-by: Robert Lippert <rlippert@google.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Hmm, it is using a preferred policy but I see your point as expectations
of an application parsing numa_maps have been broken.  The patch makes
non-obvious assumptions about how and when MPOL_F_MORON gets set which
could change in the future and be missed. Use this instead? It might need
to be changed again if there is a need to control whether automatic numa
balancing can be enabled or disabled on a per-process basis.

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index c2ccec0..c1a2573 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -120,6 +120,14 @@ static struct mempolicy default_policy = {
 
 static struct mempolicy preferred_node_policy[MAX_NUMNODES];
 
+/* Returns true if the policy is the default policy */
+static bool mpol_is_default(struct mempolicy *pol)
+{
+	return !pol ||
+		pol == &default_policy ||
+		pol == &preferred_node_policy[numa_node_id()];
+}
+
 static struct mempolicy *get_task_policy(struct task_struct *p)
 {
 	struct mempolicy *pol = p->mempolicy;
@@ -2856,7 +2864,7 @@ void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
 	unsigned short mode = MPOL_DEFAULT;
 	unsigned short flags = 0;
 
-	if (pol && pol != &default_policy) {
+	if (!mpol_is_default(pol)) {
 		mode = pol->mode;
 		flags = pol->flags;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
