Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id DC83E6B0074
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 08:02:07 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id y13so4726951pdi.16
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 05:02:07 -0700 (PDT)
Received: from out4133-146.mail.aliyun.com (out4133-146.mail.aliyun.com. [42.120.133.146])
        by mx.google.com with ESMTP id xd9si2096830pab.19.2014.06.09.05.02.04
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 05:02:07 -0700 (PDT)
Reply-To: "=?GBK?B?1cW+siizpLnIKQ==?=" <hillf.zj@alibaba-inc.com>
From: "=?GBK?B?1cW+siizpLnIKQ==?=" <hillf.zj@alibaba-inc.com>
Subject: Re: 3.15-rc8 mm/filemap.c:202 BUG
Date: Mon, 09 Jun 2014 20:01:54 +0800
Message-ID: <013901cf83da$9b8d4670$d2a7d350$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_013A_01CF841D.A9B6EF10"
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Hugh Dickins' <hughd@google.com>
Cc: 'Sasha Levin' <sasha.levin@oracle.com>, 'Andrew Morton' <akpm@linux-foundation.org>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Konstantin Khlebnikov' <koct9i@gmail.com>, 'Dave Jones' <davej@redhat.com>, linux-mm@kvack.org, 'Linus Torvalds' <torvalds@linux-foundation.org>

This is a multipart message in MIME format.

------=_NextPart_000_013A_01CF841D.A9B6EF10
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 7bit

Hi Hugh
 
On Fri, Jun 6, 2014 at 4:05 PM, Hugh Dickins <hughd@google.com> wrote:
>
> Though I'd wanted to see the remove_migration_pte oops as a key to the
> page_mapped bug, my guess is that they're actually independent.

> 

In the 3.15-rc8 tree, along the migration path

/*

    * Corner case handling:

    * 1. When a new swap-cache page is read into, it is added to the LRU

    * and treated as swapcache but it has no rmap yet.

    * Calling try_to_unmap() against a page->mapping==NULL page will

    * trigger a BUG.  So handle it here.

    * 2. An orphaned page (see truncate_complete_page) might have

    * fs-private metadata. The page can be picked up due to memory

    * offlining.  Everywhere else except page reclaim, the page is

    * invisible to the vm, so the page can not be migrated.  So try to

    * free the metadata, so the page can be freed.

    */

    if (!page->mapping) {

       VM_BUG_ON_PAGE(PageAnon(page), page);

       if (page_has_private(page)) {

           try_to_free_buffers(page);

           goto uncharge;

       }

       goto skip_unmap;

    }

 

    /* Establish migration ptes or remove ptes */

    try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);

 

skip_unmap:

    if (!page_mapped(page))

       rc = move_to_new_page(newpage, page, remap_swapcache, mode);

 

Here a page is migrated even not mapped and with no mapping! 

 

    mapping = page_mapping(page);

    if (!mapping)

       rc = migrate_page(mapping, newpage, page, mode);

 

 

    if (!mapping) {

       /* Anonymous page without mapping */

       if (page_count(page) != expected_count)

           return -EAGAIN;

       return MIGRATEPAGE_SUCCESS;

    }

 

And seems a file cache page is treated in the way of Anon.

Is that right?

 

Thanks

Hillf

 


------=_NextPart_000_013A_01CF841D.A9B6EF10
Content-Type: text/html;
	charset="gb2312"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" =
xmlns:o=3D"urn:schemas-microsoft-com:office:office" =
xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" =
xmlns=3D"http://www.w3.org/TR/REC-html40"><head><meta =
http-equiv=3DContent-Type content=3D"text/html; charset=3Dgb2312"><meta =
name=3DGenerator content=3D"Microsoft Word 14 (filtered =
medium)"><style><!--
/* Font Definitions */
@font-face
	{font-family:Wingdings;
	panose-1:5 0 0 0 0 0 0 0 0 0;}
@font-face
	{font-family:=CB=CE=CC=E5;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:=CB=CE=CC=E5;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:"\@=CB=CE=CC=E5";
	panose-1:2 1 6 0 3 1 1 1 1 1;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	margin-bottom:.0001pt;
	text-align:justify;
	text-justify:inter-ideograph;
	font-size:10.5pt;
	font-family:"Calibri","sans-serif";}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:purple;
	text-decoration:underline;}
pre
	{mso-style-priority:99;
	mso-style-link:"HTML =D4=A4=C9=E8=B8=F1=CA=BD Char";
	margin:0cm;
	margin-bottom:.0001pt;
	font-size:12.0pt;
	font-family:=CB=CE=CC=E5;}
p.MsoListParagraph, li.MsoListParagraph, div.MsoListParagraph
	{mso-style-priority:34;
	margin:0cm;
	margin-bottom:.0001pt;
	text-align:justify;
	text-justify:inter-ideograph;
	text-indent:21.0pt;
	font-size:10.5pt;
	font-family:"Calibri","sans-serif";}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri","sans-serif";
	color:windowtext;}
span.HTMLChar
	{mso-style-name:"HTML =D4=A4=C9=E8=B8=F1=CA=BD Char";
	mso-style-priority:99;
	mso-style-link:"HTML =D4=A4=C9=E8=B8=F1=CA=BD";
	font-family:=CB=CE=CC=E5;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-family:"Calibri","sans-serif";}
/* Page Definitions */
@page WordSection1
	{size:612.0pt 792.0pt;
	margin:72.0pt 90.0pt 72.0pt 90.0pt;}
div.WordSection1
	{page:WordSection1;}
/* List Definitions */
@list l0
	{mso-list-id:1468357255;
	mso-list-type:hybrid;
	mso-list-template-ids:195210426 222333650 67698691 67698693 67698689 =
67698691 67698693 67698689 67698691 67698693;}
@list l0:level1
	{mso-level-start-at:0;
	mso-level-number-format:bullet;
	mso-level-text:\F0D8;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:18.0pt;
	text-indent:-18.0pt;
	font-family:Wingdings;
	mso-fareast-font-family:=CB=CE=CC=E5;
	mso-bidi-font-family:=CB=CE=CC=E5;}
@list l0:level2
	{mso-level-number-format:bullet;
	mso-level-text:\F06E;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:42.0pt;
	text-indent:-21.0pt;
	font-family:Wingdings;}
@list l0:level3
	{mso-level-number-format:bullet;
	mso-level-text:\F075;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:63.0pt;
	text-indent:-21.0pt;
	font-family:Wingdings;}
@list l0:level4
	{mso-level-number-format:bullet;
	mso-level-text:\F06C;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:84.0pt;
	text-indent:-21.0pt;
	font-family:Wingdings;}
@list l0:level5
	{mso-level-number-format:bullet;
	mso-level-text:\F06E;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:105.0pt;
	text-indent:-21.0pt;
	font-family:Wingdings;}
@list l0:level6
	{mso-level-number-format:bullet;
	mso-level-text:\F075;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:126.0pt;
	text-indent:-21.0pt;
	font-family:Wingdings;}
@list l0:level7
	{mso-level-number-format:bullet;
	mso-level-text:\F06C;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:147.0pt;
	text-indent:-21.0pt;
	font-family:Wingdings;}
@list l0:level8
	{mso-level-number-format:bullet;
	mso-level-text:\F06E;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:168.0pt;
	text-indent:-21.0pt;
	font-family:Wingdings;}
@list l0:level9
	{mso-level-number-format:bullet;
	mso-level-text:\F075;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:189.0pt;
	text-indent:-21.0pt;
	font-family:Wingdings;}
@list l1
	{mso-list-id:1871990377;
	mso-list-type:hybrid;
	mso-list-template-ids:381600890 -512204000 67698691 67698693 67698689 =
67698691 67698693 67698689 67698691 67698693;}
@list l1:level1
	{mso-level-start-at:0;
	mso-level-number-format:bullet;
	mso-level-text:\F0D8;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	text-indent:-18.0pt;
	font-family:Wingdings;
	mso-fareast-font-family:=CB=CE=CC=E5;
	mso-bidi-font-family:=CB=CE=CC=E5;}
@list l1:level2
	{mso-level-number-format:bullet;
	mso-level-text:\F06E;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:60.0pt;
	text-indent:-21.0pt;
	font-family:Wingdings;}
@list l1:level3
	{mso-level-number-format:bullet;
	mso-level-text:\F075;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:81.0pt;
	text-indent:-21.0pt;
	font-family:Wingdings;}
@list l1:level4
	{mso-level-number-format:bullet;
	mso-level-text:\F06C;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:102.0pt;
	text-indent:-21.0pt;
	font-family:Wingdings;}
@list l1:level5
	{mso-level-number-format:bullet;
	mso-level-text:\F06E;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:123.0pt;
	text-indent:-21.0pt;
	font-family:Wingdings;}
@list l1:level6
	{mso-level-number-format:bullet;
	mso-level-text:\F075;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:144.0pt;
	text-indent:-21.0pt;
	font-family:Wingdings;}
@list l1:level7
	{mso-level-number-format:bullet;
	mso-level-text:\F06C;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:165.0pt;
	text-indent:-21.0pt;
	font-family:Wingdings;}
@list l1:level8
	{mso-level-number-format:bullet;
	mso-level-text:\F06E;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:186.0pt;
	text-indent:-21.0pt;
	font-family:Wingdings;}
@list l1:level9
	{mso-level-number-format:bullet;
	mso-level-text:\F075;
	mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:207.0pt;
	text-indent:-21.0pt;
	font-family:Wingdings;}
ol
	{margin-bottom:0cm;}
ul
	{margin-bottom:0cm;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]--></head><body lang=3DZH-CN link=3Dblue =
vlink=3Dpurple style=3D'text-justify-trim:punctuation'><div =
class=3DWordSection1><pre><span lang=3DEN-US style=3D'color:black'>Hi =
Hugh<o:p></o:p></span></pre><pre><span lang=3DEN-US =
style=3D'color:black'><o:p>&nbsp;</o:p></span></pre><pre><span =
lang=3DEN-US style=3D'color:black'>On Fri, Jun 6, 2014 at 4:05 PM, Hugh =
Dickins &lt;hughd@google.com&gt; wrote:<br>&gt;<br>&gt; Though I'd =
wanted to see the remove_migration_pte oops as a key to the<br>&gt; =
page_mapped bug, my guess is that they're actually =
independent.<o:p></o:p></span></pre><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left'><span lang=3DEN-US =
style=3D'font-size:12.0pt;font-family:=CB=CE=CC=E5;color:black'>&gt;<o:p>=
&nbsp;</o:p></span></p><p class=3DMsoNormal><span lang=3DEN-US>In the =
3.15-rc8 tree, along the migration path<o:p></o:p></span></p><p =
class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-indent:22.0pt;text-autospace:none'><span =
lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>/*<o:p></o:p></span><=
/p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;  =
* Corner case handling:<o:p></o:p></span></p><p class=3DMsoNormal =
align=3Dleft style=3D'text-align:left;text-autospace:none'><span =
lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;  =
* 1. When a new swap-cache page is read into, it is added to the =
LRU<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;  =
* and treated as swapcache but it has no rmap =
yet.<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;  =
* Calling try_to_unmap() against a page-&gt;mapping=3D=3DNULL page =
will<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;  =
* trigger a BUG.&nbsp; So handle it here.<o:p></o:p></span></p><p =
class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;  =
* 2. An orphaned page (see truncate_complete_page) might =
have<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;  =
* fs-private metadata. The page can be picked up due to =
memory<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;  =
* offlining.&nbsp; Everywhere else except page reclaim, the page =
is<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;  =
* invisible to the vm, so the page can not be migrated.&nbsp; So try =
to<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;  =
* free the metadata, so the page can be freed.<o:p></o:p></span></p><p =
class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;  =
*/<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp; =
if (!page-&gt;mapping) {<o:p></o:p></span></p><p class=3DMsoNormal =
align=3Dleft style=3D'text-align:left;text-autospace:none'><span =
lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; VM_BUG_ON_PAGE(PageAnon(page), =
page);<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; if (page_has_private(page)) {<o:p></o:p></span></p><p =
class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
try_to_free_buffers(page);<o:p></o:p></span></p><p class=3DMsoNormal =
align=3Dleft style=3D'text-align:left;text-autospace:none'><span =
lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; goto =
uncharge;<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; }<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; goto skip_unmap;<o:p></o:p></span></p><p =
class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp; =
}<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'><o:p>&nbsp;</o:p></sp=
an></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp; =
/* Establish migration ptes or remove ptes */<o:p></o:p></span></p><p =
class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp; =
try_to_unmap(page, =
TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);<o:p></o:p></span></p><=
p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'><o:p>&nbsp;</o:p></sp=
an></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>skip_unmap:<o:p></o:p=
></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp; =
if (!page_mapped(page))<o:p></o:p></span></p><p class=3DMsoNormal =
align=3Dleft style=3D'text-align:left;text-autospace:none'><span =
lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; rc =3D move_to_new_page(newpage, page, remap_swapcache, =
mode);<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'><o:p>&nbsp;</o:p></sp=
an></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>Here a page is =
migrated even not mapped and with no mapping! <o:p></o:p></span></p><p =
class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'><o:p>&nbsp;</o:p></sp=
an></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp; =
mapping =3D page_mapping(page);<o:p></o:p></span></p><p =
class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp; =
if (!mapping)<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; rc =3D migrate_page(mapping, newpage, page, =
mode);<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'><o:p>&nbsp;</o:p></sp=
an></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'><o:p>&nbsp;</o:p></sp=
an></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp; =
if (!mapping) {<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; /* Anonymous page without mapping =
*/<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; if (page_count(page) !=3D =
expected_count)<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return =
-EAGAIN;<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; return MIGRATEPAGE_SUCCESS;<o:p></o:p></span></p><p =
class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>&nbsp;&nbsp;&nbsp; =
}<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'><o:p>&nbsp;</o:p></sp=
an></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>And seems a file =
cache page is treated in the way of Anon.<o:p></o:p></span></p><p =
class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>Is that =
right?<o:p></o:p></span></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'><o:p>&nbsp;</o:p></sp=
an></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>Thanks<o:p></o:p></sp=
an></p><p class=3DMsoNormal align=3Dleft =
style=3D'text-align:left;text-autospace:none'><span lang=3DEN-US =
style=3D'font-size:11.0pt;font-family:=CB=CE=CC=E5'>Hillf<o:p></o:p></spa=
n></p><p class=3DMsoNormal><span =
lang=3DEN-US><o:p>&nbsp;</o:p></span></p></div></body></html>
------=_NextPart_000_013A_01CF841D.A9B6EF10--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
