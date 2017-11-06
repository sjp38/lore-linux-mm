Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 695FD6B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 08:26:52 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id b192so12809119pga.14
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 05:26:52 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id e7si12278984pfb.298.2017.11.06.05.26.50
        for <linux-mm@kvack.org>;
        Mon, 06 Nov 2017 05:26:51 -0800 (PST)
Subject: Re: Re: [PATCH] ksm : use checksum and memcmp for rb_tree
References: <1509364987-29608-1-git-send-email-kyeongdon.kim@lge.com>
 <CAGqmi75C7DWczUw47+gtO8NkwtHVsBNha5zhzbnFLh=DoN08xQ@mail.gmail.com>
From: Kyeongdon Kim <kyeongdon.kim@lge.com>
Message-ID: <68ee9507-f48d-e06e-4557-035a23c865ab@lge.com>
Date: Mon, 6 Nov 2017 22:26:48 +0900
MIME-Version: 1.0
In-Reply-To: <CAGqmi75C7DWczUw47+gtO8NkwtHVsBNha5zhzbnFLh=DoN08xQ@mail.gmail.com>
Content-Type: multipart/alternative;
 boundary="------------27E5AB2033C513009997A6E4"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, broonie@kernel.org, mhocko@suse.com, mingo@kernel.org, jglisse@redhat.com, Arvind Yadav <arvind.yadav.cs@gmail.com>, imbrenda@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, bongkyu.kim@lge.com, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------27E5AB2033C513009997A6E4
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit

On 2017-10-30 i??i?? 10:22, Timofey Titovets wrote:
> 2017-10-30 15:03 GMT+03:00 Kyeongdon Kim <kyeongdon.kim@lge.com>:
> > The current ksm is using memcmp to insert and search 'rb_tree'.
> > It does cause very expensive computation cost.
> > In order to reduce the time of this operation,
> > we have added a checksum to traverse before memcmp operation.
> >
> > Nearly all 'rb_node' in stable_tree_insert() function
> > can be inserted as a checksum, most of it is possible
> > in unstable_tree_search_insert() function.
> > In stable_tree_search() function, the checksum may be an additional.
> > But, checksum check duration is extremely small.
> > Considering the time of the whole cmp_and_merge_page() function,
> > it requires very little cost on average.
> >
> > Using this patch, we compared the time of ksm_do_scan() function
> > by adding kernel trace at the start-end position of operation.
> > (ARM 32bit target android device,
> > over 1000 sample time gap stamps average)
> >
> > On original KSM scan avg duration = 0.0166893 sec
> > 24991.975619 : ksm_do_scan_start: START: ksm_do_scan
> > 24991.990975 : ksm_do_scan_end: END: ksm_do_scan
> > 24992.008989 : ksm_do_scan_start: START: ksm_do_scan
> > 24992.016839 : ksm_do_scan_end: END: ksm_do_scan
> > ...
> >
> > On patch KSM scan avg duration = 0.0041157 sec
> > 41081.461312 : ksm_do_scan_start: START: ksm_do_scan
> > 41081.466364 : ksm_do_scan_end: END: ksm_do_scan
> > 41081.484767 : ksm_do_scan_start: START: ksm_do_scan
> > 41081.487951 : ksm_do_scan_end: END: ksm_do_scan
> > ...
> >
> > We have tested randomly so many times for the stability
> > and couldn't see any abnormal issue until now.
> > Also, we found out this patch can make some good advantage
> > for the power consumption than KSM default enable.
> >
> > Signed-off-by: Kyeongdon Kim <kyeongdon.kim@lge.com>
> > ---
> > mm/ksm.c | 49 +++++++++++++++++++++++++++++++++++++++++++++----
> > 1 file changed, 45 insertions(+), 4 deletions(-)
> >
> > diff --git a/mm/ksm.c b/mm/ksm.c
> > index be8f457..66ab4f4 100644
> > --- a/mm/ksm.c
> > +++ b/mm/ksm.c
> > @@ -150,6 +150,7 @@ struct stable_node {
> > struct hlist_head hlist;
> > union {
> > unsigned long kpfn;
> > + u32 oldchecksum;
> > unsigned long chain_prune_time;
> > };
> > /*
>
> May be just checksum? i.e. that's can be "old", where checksum can 
> change,
> in stable tree, checksum also stable.
>
> Also, as checksum are stable, may be that make a sense to move it out
> of union? (I'm afraid of clashes)
>
> Also, you miss update comment above struct stable_node, about checksum 
> var.
>
Thanks for your comment, and we may change those lines like below :

+ * @oldchecksum: previous checksum of the page about a stable_node
 A  * @nid: NUMA node id of stable tree in which linked (may not match kpfn)
 A  */
 A struct stable_node {
@@ -159,6 +160,7 @@ struct stable_node {
 A A A A A A A A  */
 A #define STABLE_NODE_CHAIN -1024
 A A A A A A A  int rmap_hlist_len;
+A A A A A A  u32 oldchecksum;
 A #ifdef CONFIG_NUMA

And I think if checksum are matched,
then we can use original memcmp logic in stable tree.
the worst case that I imagine is no page merging(just in that moment).
But, in my humble opinion, there will be no critical memory issue. but 
just return.
(as I said, we tested a lot to check some abnormal memory operation,
but so far, so good - only performance improvement)

> > @@ -1522,7 +1523,7 @@ static __always_inline struct page 
> *chain(struct stable_node **s_n_d,
> > * This function returns the stable tree node of identical content if 
> found,
> > * NULL otherwise.
> > */
> > -static struct page *stable_tree_search(struct page *page)
> > +static struct page *stable_tree_search(struct page *page, u32 
> checksum)
> > {
> > int nid;
> > struct rb_root *root;
> > @@ -1540,6 +1541,8 @@ static struct page *stable_tree_search(struct 
> page *page)
> >
> > nid = get_kpfn_nid(page_to_pfn(page));
> > root = root_stable_tree + nid;
> > + if (!checksum)
> > + return NULL;
>
> That's not a pointer, and 0x0 - is a valid checksum.
> Also, jhash2 not so collision free, i.e.:
> jhash2((uint32_t *) &num, 2, 17);
>
> Example of collisions, where hash = 0x0:
> hash: 0x0 - num: 610041898
> hash: 0x0 - num: 4893164379
> hash: 0x0 - num: 16423540221
> hash: 0x0 - num: 29036382188
>
> You also compare values, so hash = 0, is a acceptable checksum.
>
well, if then, I can remove this check line.
> > --
> > 2.6.2
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org. For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> Thanks,
> anyway in general idea looks good.
Thanks a lot :)
Actually, our organization want to use this KSM feature in general,
but, current logic needs too high cost.
So I wish to change more light version.
Please kindly give your opinion on this idea.

Thanks,
Kyeongdon Kim
>
> Reviewed-by: Timofey Titovets <nefelim4ag@gmail.com>
>
> -- 
> Have a nice day,
> Timofey.


--------------27E5AB2033C513009997A6E4
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    On 2017-10-30 i??i?? 10:22, Timofey Titovets wrote:<br>
    <blockquote type="cite"
cite="mid:%3CCAGqmi75C7DWczUw47+gtO8NkwtHVsBNha5zhzbnFLh=DoN08xQ@mail.gmail.com%3E">2017-10-30
      15:03 GMT+03:00 Kyeongdon Kim <a class="moz-txt-link-rfc2396E" href="mailto:kyeongdon.kim@lge.com">&lt;kyeongdon.kim@lge.com&gt;</a>:
      <br>
      &gt; The current ksm is using memcmp to insert and search
      'rb_tree'.
      <br>
      &gt; It does cause very expensive computation cost.
      <br>
      &gt; In order to reduce the time of this operation,
      <br>
      &gt; we have added a checksum to traverse before memcmp operation.
      <br>
      &gt;
      <br>
      &gt; Nearly all 'rb_node' in stable_tree_insert() function
      <br>
      &gt; can be inserted as a checksum, most of it is possible
      <br>
      &gt; in unstable_tree_search_insert() function.
      <br>
      &gt; In stable_tree_search() function, the checksum may be an
      additional.
      <br>
      &gt; But, checksum check duration is extremely small.
      <br>
      &gt; Considering the time of the whole cmp_and_merge_page()
      function,
      <br>
      &gt; it requires very little cost on average.
      <br>
      &gt;
      <br>
      &gt; Using this patch, we compared the time of ksm_do_scan()
      function
      <br>
      &gt; by adding kernel trace at the start-end position of
      operation.
      <br>
      &gt; (ARM 32bit target android device,
      <br>
      &gt; over 1000 sample time gap stamps average)
      <br>
      &gt;
      <br>
      &gt; On original KSM scan avg duration = 0.0166893 sec
      <br>
      &gt; 24991.975619 : ksm_do_scan_start: START: ksm_do_scan
      <br>
      &gt; 24991.990975 : ksm_do_scan_end: END: ksm_do_scan
      <br>
      &gt; 24992.008989 : ksm_do_scan_start: START: ksm_do_scan
      <br>
      &gt; 24992.016839 : ksm_do_scan_end: END: ksm_do_scan
      <br>
      &gt; ...
      <br>
      &gt;
      <br>
      &gt; On patch KSM scan avg duration = 0.0041157 sec
      <br>
      &gt; 41081.461312 : ksm_do_scan_start: START: ksm_do_scan
      <br>
      &gt; 41081.466364 : ksm_do_scan_end: END: ksm_do_scan
      <br>
      &gt; 41081.484767 : ksm_do_scan_start: START: ksm_do_scan
      <br>
      &gt; 41081.487951 : ksm_do_scan_end: END: ksm_do_scan
      <br>
      &gt; ...
      <br>
      &gt;
      <br>
      &gt; We have tested randomly so many times for the stability
      <br>
      &gt; and couldn't see any abnormal issue until now.
      <br>
      &gt; Also, we found out this patch can make some good advantage
      <br>
      &gt; for the power consumption than KSM default enable.
      <br>
      &gt;
      <br>
      &gt; Signed-off-by: Kyeongdon Kim <a class="moz-txt-link-rfc2396E" href="mailto:kyeongdon.kim@lge.com">&lt;kyeongdon.kim@lge.com&gt;</a>
      <br>
      &gt; ---
      <br>
      &gt; mm/ksm.c | 49
      +++++++++++++++++++++++++++++++++++++++++++++----
      <br>
      &gt; 1 file changed, 45 insertions(+), 4 deletions(-)
      <br>
      &gt;
      <br>
      &gt; diff --git a/mm/ksm.c b/mm/ksm.c
      <br>
      &gt; index be8f457..66ab4f4 100644
      <br>
      &gt; --- a/mm/ksm.c
      <br>
      &gt; +++ b/mm/ksm.c
      <br>
      &gt; @@ -150,6 +150,7 @@ struct stable_node {
      <br>
      &gt; struct hlist_head hlist;
      <br>
      &gt; union {
      <br>
      &gt; unsigned long kpfn;
      <br>
      &gt; + u32 oldchecksum;
      <br>
      &gt; unsigned long chain_prune_time;
      <br>
      &gt; };
      <br>
      &gt; /*
      <br>
      <br>
      May be just checksum? i.e. that's can be "old", where checksum can
      change,
      <br>
      in stable tree, checksum also stable.
      <br>
      <br>
      Also, as checksum are stable, may be that make a sense to move it
      out
      <br>
      of union? (I'm afraid of clashes)
      <br>
      <br>
      Also, you miss update comment above struct stable_node, about
      checksum var.
      <br>
      <br>
    </blockquote>
    Thanks for your comment, and we may change those lines like below :<br>
    <br>
    + * @oldchecksum: previous checksum of the page about a stable_node<br>
    A  * @nid: NUMA node id of stable tree in which linked (may not match
    kpfn)<br>
    A  */<br>
    A struct stable_node {<br>
    @@ -159,6 +160,7 @@ struct stable_node {<br>
    A A A A A A A A  */<br>
    A #define STABLE_NODE_CHAIN -1024<br>
    A A A A A A A  int rmap_hlist_len;<br>
    +A A A A A A  u32 oldchecksum;<br>
    A #ifdef CONFIG_NUMA<br>
    <br>
    And I think if checksum are matched, <br>
    then we can use original memcmp logic in stable tree.<br>
    the worst case that I imagine is no page merging(just in that
    moment). <br>
    But, in my humble opinion, there will be no critical memory issue.
    but just return.<br>
    (as I said, we tested a lot to check some abnormal memory operation,
    <br>
    but so far, so good - only performance improvement)<br>
    <br>
    <blockquote type="cite"
cite="mid:%3CCAGqmi75C7DWczUw47+gtO8NkwtHVsBNha5zhzbnFLh=DoN08xQ@mail.gmail.com%3E">&gt;
      @@ -1522,7 +1523,7 @@ static __always_inline struct page
      *chain(struct stable_node **s_n_d,
      <br>
      &gt; * This function returns the stable tree node of identical
      content if found,
      <br>
      &gt; * NULL otherwise.
      <br>
      &gt; */
      <br>
      &gt; -static struct page *stable_tree_search(struct page *page)
      <br>
      &gt; +static struct page *stable_tree_search(struct page *page,
      u32 checksum)
      <br>
      &gt; {
      <br>
      &gt; int nid;
      <br>
      &gt; struct rb_root *root;
      <br>
      &gt; @@ -1540,6 +1541,8 @@ static struct page
      *stable_tree_search(struct page *page)
      <br>
      &gt;
      <br>
      &gt; nid = get_kpfn_nid(page_to_pfn(page));
      <br>
      &gt; root = root_stable_tree + nid;
      <br>
      &gt; + if (!checksum)
      <br>
      &gt; + return NULL;
      <br>
      <br>
      That's not a pointer, and 0x0 - is a valid checksum.
      <br>
      Also, jhash2 not so collision free, i.e.:
      <br>
      jhash2((uint32_t *) &amp;num, 2, 17);
      <br>
      <br>
      Example of collisions, where hash = 0x0:
      <br>
      hash: 0x0 - num: 610041898
      <br>
      hash: 0x0 - num: 4893164379
      <br>
      hash: 0x0 - num: 16423540221
      <br>
      hash: 0x0 - num: 29036382188
      <br>
      <br>
      You also compare values, so hash = 0, is a acceptable checksum.
      <br>
      <br>
    </blockquote>
    well, if then, I can remove this check line.<br>
    <blockquote type="cite"
cite="mid:%3CCAGqmi75C7DWczUw47+gtO8NkwtHVsBNha5zhzbnFLh=DoN08xQ@mail.gmail.com%3E">&gt;
      --
      <br>
      &gt; 2.6.2
      <br>
      &gt;
      <br>
      &gt; --
      <br>
      &gt; To unsubscribe, send a message with 'unsubscribe linux-mm' in
      <br>
      &gt; the body to <a class="moz-txt-link-abbreviated" href="mailto:majordomo@kvack.org">majordomo@kvack.org</a>. For more info on Linux MM,
      <br>
      &gt; see: <a class="moz-txt-link-freetext" href="http://www.linux-mm.org/">http://www.linux-mm.org/</a> .
      <br>
      &gt; Don't email: &lt;a href=mailto:<a class="moz-txt-link-rfc2396E" href="mailto:dont@kvack.org">"dont@kvack.org"</a>&gt;
      <a class="moz-txt-link-abbreviated" href="mailto:email@kvack.org">email@kvack.org</a> &lt;/a&gt;
      <br>
      <br>
      Thanks,
      <br>
      anyway in general idea looks good.
      <br>
    </blockquote>
    Thanks a lot :)<br>
    Actually, our organization want to use this KSM feature in general,<br>
    but, current logic needs too high cost.<br>
    So I wish to change more light version.<br>
    Please kindly give your opinion on this idea.<br>
    <br>
    Thanks,<br>
    Kyeongdon Kim<br>
    <span style="color: rgb(0, 0, 0); font-family: gulim; font-size:
      13px; font-style: normal; font-variant-ligatures: normal;
      font-variant-caps: normal; font-weight: normal; letter-spacing:
      normal; orphans: 2; text-align: left; text-indent: 0px;
      text-transform: none; white-space: normal; widows: 2;
      word-spacing: 0px; -webkit-text-stroke-width: 0px;
      text-decoration-style: initial; text-decoration-color: initial;
      display: inline !important; float: none;"></span>
    <blockquote type="cite"
cite="mid:%3CCAGqmi75C7DWczUw47+gtO8NkwtHVsBNha5zhzbnFLh=DoN08xQ@mail.gmail.com%3E"><br>
      Reviewed-by: Timofey Titovets <a class="moz-txt-link-rfc2396E" href="mailto:nefelim4ag@gmail.com">&lt;nefelim4ag@gmail.com&gt;</a>
      <br>
      <br>
      -- <br>
      Have a nice day,
      <br>
      Timofey.
      <br>
    </blockquote>
    <br>
  </body>
</html>

--------------27E5AB2033C513009997A6E4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
