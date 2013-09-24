Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7C26B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 03:01:24 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id ar20so8274619iec.4
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 00:01:24 -0700 (PDT)
Received: by mail-ve0-f169.google.com with SMTP id db12so3323955veb.28
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 00:01:21 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 24 Sep 2013 15:01:20 +0800
Message-ID: <CAF7GXvqKg2rgeSZv5rTEvtz15hcg13Mhb+x5e5h=FUY8zQH09A@mail.gmail.com>
Subject: sched: Set preferred NUMA node based on number of private faults
From: "Figo.zhang" <figo1802@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b343eca3407ba04e71bb437
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>

--047d7b343eca3407ba04e71bb437
Content-Type: text/plain; charset=ISO-8859-1

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4baf12e..8e2a364 100644
--- a/mm/mempolicy.c<https://git.kernel.org/cgit/linux/kernel/git/mel/linux-balancenuma.git/tree/mm/mempolicy.c?h=sched-numa-balancing-stick-v8r17&id=d182f60b02e670ca2add388813b499ce275a9222>
+++ b/mm/mempolicy.c<https://git.kernel.org/cgit/linux/kernel/git/mel/linux-balancenuma.git/tree/mm/mempolicy.c?h=sched-numa-balancing-stick-v8r17&id=e5c6a5c945780aae8ea4e034cb230d0407c06d04>
@@ -2292,9 +2292,11 @@ int mpol_misplaced(struct page *page, struct
vm_area_struct *vma, unsigned long
 /* Migrate the page towards the node whose CPU is referencing it */
if (pol->flags & MPOL_F_MORON) {
- int last_nid;
+ int last_nidpid;
+ int this_nidpid;
 polnid = numa_node_id();
+ this_nidpid = nid_pid_to_nidpid(polnid, current->pid);
 /*
* Multi-stage node selection is used in conjunction
@@ -2317,8 +2319,8 @@ int mpol_misplaced(struct page *page, struct
vm_area_struct *vma, unsigned long
* it less likely we act on an unlikely task<->page
* relation.
*/
- last_nid = page_nid_xchg_last(page, polnid);
- if (last_nid != polnid)
+ last_nidpid = page_nidpid_xchg_last(page, this_nidpid);
+ if (!nidpid_pid_unset(last_nidpid) && nidpid_to_nid(last_nidpid) !=
polnid)

=>if the page is the first access, so nidpid_pid_unset(last_nidpid) return
true, so we should not check and migrate the first access page if curnid !=
polnid.


- last_nid = page_nid_xchg_last(page, polnid);
- if (last_nid != polnid)
+ last_nidpid = page_nidpid_xchg_last(page, this_nidpid);
+ if (nidpid_pid_unset(last_nidpid))
+ goto out;
+ else if (nidpid_to_nid(last_nidpid) != polnid)

--047d7b343eca3407ba04e71bb437
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"" style=3D"font-weight:bold;margin-top:1em;c=
olor:black;font-family:monospace;font-size:13px;white-space:pre">diff --git=
 a/mm/mempolicy.c b/mm/mempolicy.c<br>index 4baf12e..8e2a364 100644<br>--- =
a/<a href=3D"https://git.kernel.org/cgit/linux/kernel/git/mel/linux-balance=
numa.git/tree/mm/mempolicy.c?h=3Dsched-numa-balancing-stick-v8r17&amp;id=3D=
d182f60b02e670ca2add388813b499ce275a9222" style=3D"color:blue;text-decorati=
on:none">mm/mempolicy.c</a><br>
+++ b/<a href=3D"https://git.kernel.org/cgit/linux/kernel/git/mel/linux-bal=
ancenuma.git/tree/mm/mempolicy.c?h=3Dsched-numa-balancing-stick-v8r17&amp;i=
d=3De5c6a5c945780aae8ea4e034cb230d0407c06d04" style=3D"color:blue;text-deco=
ration:none">mm/mempolicy.c</a></div>
<div class=3D"" style=3D"color:rgb(0,0,153);font-family:monospace;font-size=
:13px;white-space:pre">@@ -2292,9 +2292,11 @@ int mpol_misplaced(struct pag=
e *page, struct vm_area_struct *vma, unsigned long</div><div class=3D"" sty=
le=3D"color:rgb(51,51,51);font-family:monospace;font-size:13px;white-space:=
pre">
 </div><div class=3D"" style=3D"color:rgb(51,51,51);font-family:monospace;f=
ont-size:13px;white-space:pre"> 	/* Migrate the page towards the node whose=
 CPU is referencing it */</div><div class=3D"" style=3D"color:rgb(51,51,51)=
;font-family:monospace;font-size:13px;white-space:pre">
 	if (pol-&gt;flags &amp; MPOL_F_MORON) {</div><div class=3D"" style=3D"col=
or:red;font-family:monospace;font-size:13px;white-space:pre">-		int last_ni=
d;</div><div class=3D"" style=3D"color:green;font-family:monospace;font-siz=
e:13px;line-height:normal;white-space:pre">
+		int last_nidpid;</div><div class=3D"" style=3D"color:green;font-family:m=
onospace;font-size:13px;line-height:normal;white-space:pre">+		int this_nid=
pid;</div><div class=3D"" style=3D"color:rgb(51,51,51);font-family:monospac=
e;font-size:13px;white-space:pre">
 </div><div class=3D"" style=3D"color:rgb(51,51,51);font-family:monospace;f=
ont-size:13px;white-space:pre"> 		polnid =3D numa_node_id();</div><div clas=
s=3D"" style=3D"color:green;font-family:monospace;font-size:13px;line-heigh=
t:normal;white-space:pre">
+		this_nidpid =3D nid_pid_to_nidpid(polnid, current-&gt;pid);</div><div cl=
ass=3D"" style=3D"color:rgb(51,51,51);font-family:monospace;font-size:13px;=
white-space:pre"> </div><div class=3D"" style=3D"color:rgb(51,51,51);font-f=
amily:monospace;font-size:13px;white-space:pre">
 		/*</div><div class=3D"" style=3D"color:rgb(51,51,51);font-family:monospa=
ce;font-size:13px;white-space:pre"> 		 * Multi-stage node selection is used=
 in conjunction</div><div class=3D"" style=3D"color:rgb(0,0,153);font-famil=
y:monospace;font-size:13px;white-space:pre">
@@ -2317,8 +2319,8 @@ int mpol_misplaced(struct page *page, struct vm_area_=
struct *vma, unsigned long</div><div class=3D"" style=3D"color:rgb(51,51,51=
);font-family:monospace;font-size:13px;white-space:pre"> 		 * it less likel=
y we act on an unlikely task&lt;-&gt;page</div>
<div class=3D"" style=3D"color:rgb(51,51,51);font-family:monospace;font-siz=
e:13px;white-space:pre"> 		 * relation.</div><div class=3D"" style=3D"color=
:rgb(51,51,51);font-family:monospace;font-size:13px;white-space:pre"> 		 */=
</div>
<div class=3D"" style=3D"color:red;font-family:monospace;font-size:13px;whi=
te-space:pre">-		last_nid =3D page_nid_xchg_last(page, polnid);</div><div c=
lass=3D"" style=3D"color:red;font-family:monospace;font-size:13px;white-spa=
ce:pre">
-		if (last_nid !=3D polnid)</div><div class=3D"" style=3D"color:green;font=
-family:monospace;font-size:13px;line-height:normal;white-space:pre">+		las=
t_nidpid =3D page_nidpid_xchg_last(page, this_nidpid);</div><div class=3D""=
 style=3D"color:green;font-family:monospace;font-size:13px;line-height:norm=
al;white-space:pre">
+		if (!nidpid_pid_unset(last_nidpid) &amp;&amp; nidpid_to_nid(last_nidpid)=
 !=3D polnid)</div><div class=3D"" style=3D"color:green;font-family:monospa=
ce;font-size:13px;line-height:normal;white-space:pre"><br></div><div class=
=3D"" style=3D"color:green;font-family:monospace;font-size:13px;line-height=
:normal;white-space:pre">
=3D&gt;if the page is the first access, so nidpid_pid_unset(last_nidpid) re=
turn true, so we should not check and migrate the first access page if curn=
id !=3D polnid.</div><div class=3D"" style=3D"color:green;font-family:monos=
pace;font-size:13px;line-height:normal;white-space:pre">
<br></div><div class=3D"" style=3D"color:green;font-family:monospace;font-s=
ize:13px;line-height:normal;white-space:pre"><br></div><div class=3D"" styl=
e=3D"color:green;font-family:monospace;font-size:13px;line-height:normal;wh=
ite-space:pre">
<div class=3D"" style=3D"font-size:13px;color:red">-		last_nid =3D page_nid=
_xchg_last(page, polnid);</div><div class=3D"" style=3D"font-size:13px;colo=
r:red">-		if (last_nid !=3D polnid)</div><div class=3D"" style=3D"font-size=
:13px">+		last_nidpid =3D page_nidpid_xchg_last(page, this_nidpid);</div>
<div class=3D"" style=3D"font-size:13px">+               if (<span style=3D=
"font-size:13px">nidpid_pid_unset(last_nidpid)</span><span style=3D"font-si=
ze:13px">)</span></div><div class=3D"" style=3D"font-size:13px"><span style=
=3D"font-size:13px">+                    goto out;</span></div>
<div class=3D"" style=3D"font-size:13px">+		else if (nidpid_to_nid(last_nid=
pid) !=3D polnid)</div></div><div class=3D"" style=3D"color:green;font-fami=
ly:monospace;font-size:13px;line-height:normal;white-space:pre"><br></div><=
div class=3D"" style=3D"color:green;font-family:monospace;font-size:13px;li=
ne-height:normal;white-space:pre">
<br></div></div>

--047d7b343eca3407ba04e71bb437--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
