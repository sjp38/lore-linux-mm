Date: Fri, 3 Feb 2006 18:37:34 +0900
From: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Subject: Re: [ckrm-tech] [PATCH 0/8] Pzone based CKRM memory resource
 controller
In-Reply-To: <20060203013358.6EA1F7403C@sv1.valinux.co.jp>
References: <20060119080408.24736.13148.sendpatchset@debian>
	<20060131023000.7915.71955.sendpatchset@debian>
	<1138763255.3938.27.camel@localhost.localdomain>
	<20060203013358.6EA1F7403C@sv1.valinux.co.jp>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Fri__3_Feb_2006_18_37_34_+0900_grqUuNZMmuPD7.Vx"
Message-Id: <20060203093735.16FE77402D@sv1.valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sekharan@us.ibm.com
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

--Multipart=_Fri__3_Feb_2006_18_37_34_+0900_grqUuNZMmuPD7.Vx
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Fri, 3 Feb 2006 10:33:58 +0900
KUROSAWA Takahiro <kurosawa@valinux.co.jp> wrote:
> On Tue, 31 Jan 2006 19:07:35 -0800
> chandra seetharaman <sekharan@us.ibm.com> wrote:
> 
> > I tried to use the controller but having some problems.
> > 
> > - Created class a,
> > - set guarantee to 50(with parent having 100, i expected class a to get 
> >   50% of memory in the system). 
> > - moved my shell to class a. 
> > - Issued a make in the kernel tree.
> > It consistently fails with 
> > -----------
> > make: getcwd: : Cannot allocate memory
> > Makefile:313: /scripts/Kbuild.include: No such file or directory
> > Makefile:532: /arch/i386/Makefile: No such file or directory
> > Can't open perl script "/scripts/setlocalversion": No such file or
> > directory
> > make: *** No rule to make target `/arch/i386/Makefile'.  Stop.
> > -----------
> > Note that the compilation succeeds if I move my shell to the default
> > class.
> 
> I could reproduce this problem.  Could you try the attached patch?

I'm sorry, the patch attached to my previous mail has a severe bug.
Could you try this patch instead?
Also, the code still doesn't work if you enable preemption because of
a locking problem so far...

--Multipart=_Fri__3_Feb_2006_18_37_34_+0900_grqUuNZMmuPD7.Vx
Content-Type: text/plain;
 name="memrc-pzone-gfp-fix2.diff"
Content-Disposition: attachment;
 filename="memrc-pzone-gfp-fix2.diff"
Content-Transfer-Encoding: 7bit

Index: mm/mem_rc_pzone.c
===================================================================
RCS file: /cvsroot/ckrm/memrc-pzone/mm/mem_rc_pzone.c,v
retrieving revision 1.9
diff -u -p -r1.9 mem_rc_pzone.c
--- mm/mem_rc_pzone.c	19 Jan 2006 05:40:13 -0000	1.9
+++ mm/mem_rc_pzone.c	3 Feb 2006 08:30:15 -0000
@@ -38,7 +38,7 @@ struct mem_rc {
 	unsigned long guarantee;
 	struct mem_rc_domain *rcd;
 	struct zone **zones[MAX_NUMNODES];
-	struct zonelist *zonelists[MAX_NUMNODES];
+	struct zonelist *zonelists[MAX_NUMNODES][GFP_ZONETYPES];
 };
 
 
@@ -109,7 +109,7 @@ static void *mem_rc_create(void *arg, st
 	struct zone *parent, *z, *z_ref;
 	pg_data_t *pgdat;
 	int node, allocn;
-	int i, j;
+	int i, j, k;
 
 	allocn = first_node(rcd->nodes);
 	mr = kmalloc_node(sizeof(*mr), GFP_KERNEL, allocn);
@@ -132,13 +132,16 @@ static void *mem_rc_create(void *arg, st
 		memset(mr->zones[node], 0,
 		       sizeof(*mr->zones[node]) * MAX_NR_ZONES);
 
-		mr->zonelists[node]
-			= kmalloc_node(sizeof(*mr->zonelists[node]),
-				       GFP_KERNEL, allocn);
-		if (!mr->zonelists[node])
-			goto failed;
+		for (i = 0; i < GFP_ZONETYPES; i++) {
+			mr->zonelists[node][i]
+				= kmalloc_node(sizeof(*mr->zonelists[node][i]),
+					       GFP_KERNEL, allocn);
+			if (!mr->zonelists[node][i])
+				goto failed;
 
-		memset(mr->zonelists[node], 0, sizeof(*mr->zonelists[node]));
+			memset(mr->zonelists[node][i], 0,
+			       sizeof(*mr->zonelists[node][i]));
+		}
 
 		for (i = 0; i < MAX_NR_ZONES; i++) {
 			parent = pgdat->node_zones + i;
@@ -153,21 +156,22 @@ static void *mem_rc_create(void *arg, st
 	}
 
 	for_each_node_mask(node, rcd->nodes) {
-		/* NORMAL zones and DMA zones also in HIGHMEM zonelist. */
-		zl_ref = NODE_DATA(node)->node_zonelists + __GFP_HIGHMEM;
-		zl = mr->zonelists[node];
-
-		for (j = i = 0; i < ARRAY_SIZE(zl_ref->zones); i++) {
-			z_ref = zl_ref->zones[i];
-			if (!z_ref)
-				break;
-
-			z = mr->zones[node][zone_idx(z_ref)];
-			if (!z)
-				continue;
-			zl->zones[j++] = z;
+		for (i = 0; i < GFP_ZONETYPES; i++) {
+			zl_ref = NODE_DATA(node)->node_zonelists + i;
+			zl = mr->zonelists[node][i];
+
+			for (j = k = 0; k < ARRAY_SIZE(zl_ref->zones); k++) {
+				z_ref = zl_ref->zones[k];
+				if (!z_ref)
+					break;
+
+				z = mr->zones[z_ref->zone_pgdat->node_id][zone_idx(z_ref)];
+				if (!z)
+					continue;
+				zl->zones[j++] = z;
+			}
+			zl->zones[j] = NULL;
 		}
-		zl->zones[j] = NULL;
 	}
 	up(&rcd->sem);
 
@@ -175,8 +179,10 @@ static void *mem_rc_create(void *arg, st
 
 failed:
 	for_each_node_mask(node, rcd->nodes) {
-		if (mr->zonelists[node])
-			kfree(mr->zonelists[node]);
+		for (i = 0; i < GFP_ZONETYPES; i++) {
+			if (mr->zonelists[node][i])
+				kfree(mr->zonelists[node][i]);
+		}
 
 		if (!mr->zones[node])
 			continue;
@@ -204,8 +210,10 @@ static void mem_rc_destroy(void *p)
 
 	down(&rcd->sem);
 	for (node = 0; node < MAX_NUMNODES; node++) {
-		if (mr->zonelists[node])
-			kfree(mr->zonelists[node]);
+		for (i = 0; i < GFP_ZONETYPES; i++) {
+			if (mr->zonelists[node][i])
+				kfree(mr->zonelists[node][i]);
+		}
 			
 		if (!mr->zones[node])
 			continue;
@@ -341,14 +349,15 @@ EXPORT_SYMBOL(mem_rc_get);
 struct page *alloc_page_mem_rc(int nid, gfp_t gfpmask)
 {
 	struct mem_rc *mr;
+	gfp_t zoneidx = gfpmask & GFP_ZONEMASK;
 
 	mr = mem_rc_get(current);
 	if (!mr)
 		return __alloc_pages(gfpmask, 0,
 				     NODE_DATA(nid)->node_zonelists
-				     + (gfpmask & GFP_ZONEMASK));
+				     + zoneidx);
 
-	return __alloc_pages(gfpmask, 0, mr->zonelists[nid]);
+	return __alloc_pages(gfpmask, 0, mr->zonelists[nid][zoneidx]);
 }
 EXPORT_SYMBOL(alloc_page_mem_rc);
 
@@ -364,5 +373,5 @@ struct zonelist *mem_rc_get_zonelist(int
 	if (!mr)
 		return NULL;
 
-	return mr->zonelists[nd];
+	return mr->zonelists[nd][gfpmask & GFP_ZONEMASK];
 }

--Multipart=_Fri__3_Feb_2006_18_37_34_+0900_grqUuNZMmuPD7.Vx--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
