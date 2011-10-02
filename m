Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3065A9000BD
	for <linux-mm@kvack.org>; Sun,  2 Oct 2011 09:57:10 -0400 (EDT)
Received: by yxi19 with SMTP id 19so3680744yxi.14
        for <linux-mm@kvack.org>; Sun, 02 Oct 2011 06:57:08 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 2 Oct 2011 21:57:07 +0800
Message-ID: <CADLM8XNiaxLFRZXs4NKJmoORvED-DV0bNxPF6eHsfnLqtxw09w@mail.gmail.com>
Subject: One comment on the __release_region in kernel/resource.c
From: Wei Yang <weiyang.kernel@gmail.com>
Content-Type: multipart/alternative; boundary=bcaec519638fe8fa6b04ae513bdc
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org

--bcaec519638fe8fa6b04ae513bdc
Content-Type: text/plain; charset=ISO-8859-1

Dear experts,

I am viewing the source code of __release_region() in kernel/resource.c.
And I have one comment for the performance issue.

For example, we have a resource tree like this.
10-89
   20-79
       30-49
       55-59
       60-64
       65-69
   80-89
100-279

If the caller wants to release a region of [50,59], the original code will
execute four times in the for loop in the subtree of 20-79.

After changing the code below, it will execute two times instead.

By using the "git annotate", I see this code is committed by Linus as the
initial version. So don't get more information about why this code is
written
in this way.

Maybe the case I thought will not happen in the real world?

Your comment is warmly welcome. :)

diff --git a/kernel/resource.c b/kernel/resource.c
index 8461aea..81525b4 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -931,7 +931,7 @@ void __release_region(struct resource *parent,
resource_size_t start,
       for (;;) {
               struct resource *res = *p;

-               if (!res)
+               if (!res || res->start > start)
                       break;
               if (res->start <= start && res->end >= end) {
                       if (!(res->flags & IORESOURCE_BUSY)) {

Wei Yang
Help You, Help Me

--bcaec519638fe8fa6b04ae513bdc
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Dear experts,<br><div class=3D"gmail_quote"><br>I am viewing the source cod=
e of __release_region() in kernel/resource.c.<br>And I have one comment for=
 the performance issue.<br>
<br>
For example, we have a resource tree like this.<br>
10-89<br>
=A0 =A020-79<br>
=A0 =A0 =A0 =A030-49<br>
=A0 =A0 =A0 =A055-59<br>
=A0 =A0 =A0 =A060-64<br>
=A0 =A0 =A0 =A065-69<br>
=A0 =A080-89<br>
100-279<br>
<br>
If the caller wants to release a region of [50,59], the original code will<=
br>
execute four times in the for loop in the subtree of 20-79.<br>
<br>
After changing the code below, it will execute two times instead.<br>
<br>
By using the &quot;git annotate&quot;, I see this code is committed by Linu=
s as the<br>
initial version. So don&#39;t get more information about why this code is w=
ritten<br>
in this way.<br>
<br>
Maybe the case I thought will not happen in the real world?<br>
<br>
Your comment is warmly welcome. :)<br>
<br>
diff --git a/kernel/resource.c b/kernel/resource.c<br>
index 8461aea..81525b4 100644<br>
--- a/kernel/resource.c<br>
+++ b/kernel/resource.c<br>
@@ -931,7 +931,7 @@ void __release_region(struct resource *parent,<br>
resource_size_t start,<br>
=A0 =A0 =A0 =A0for (;;) {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct resource *res =3D *p;<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!res)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!res || res-&gt;start &gt; start)<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (res-&gt;start &lt;=3D start &amp;&amp; r=
es-&gt;end &gt;=3D end) {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!(res-&gt;flags &amp; IO=
RESOURCE_BUSY)) {<br>
<font color=3D"#888888"><br>
Wei Yang<br>Help You, Help Me<br>
<br>
</font></div><br>

--bcaec519638fe8fa6b04ae513bdc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
