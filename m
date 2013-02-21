Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id C0A026B002B
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 03:45:05 -0500 (EST)
Received: by mail-yh0-f52.google.com with SMTP id q46so1573670yhf.25
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 00:45:04 -0800 (PST)
Message-ID: <5125DE85.9030409@gmail.com>
Date: Thu, 21 Feb 2013 16:44:53 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 2/8] zsmalloc: add documentation
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com> <1360780731-11708-3-git-send-email-sjenning@linux.vnet.ibm.com> <511F254D.2010909@gmail.com> <51227DF4.9020900@linux.vnet.ibm.com>
In-Reply-To: <51227DF4.9020900@linux.vnet.ibm.com>
Content-Type: multipart/alternative;
 boundary="------------080107040006080304030209"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

This is a multi-part message in MIME format.
--------------080107040006080304030209
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 02/19/2013 03:16 AM, Seth Jennings wrote:
> On 02/16/2013 12:21 AM, Ric Mason wrote:
>> On 02/14/2013 02:38 AM, Seth Jennings wrote:
>>> This patch adds a documentation file for zsmalloc at
>>> Documentation/vm/zsmalloc.txt
>>>
>>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>>> ---
>>>    Documentation/vm/zsmalloc.txt |   68
>>> +++++++++++++++++++++++++++++++++++++++++
>>>    1 file changed, 68 insertions(+)
>>>    create mode 100644 Documentation/vm/zsmalloc.txt
>>>
>>> diff --git a/Documentation/vm/zsmalloc.txt
>>> b/Documentation/vm/zsmalloc.txt
>>> new file mode 100644
>>> index 0000000..85aa617
>>> --- /dev/null
>>> +++ b/Documentation/vm/zsmalloc.txt
>>> @@ -0,0 +1,68 @@
>>> +zsmalloc Memory Allocator
>>> +
>>> +Overview
>>> +
>>> +zmalloc a new slab-based memory allocator,
>>> +zsmalloc, for storing compressed pages.  It is designed for
>>> +low fragmentation and high allocation success rate on
>>> +large object, but <= PAGE_SIZE allocations.
>>> +
>>> +zsmalloc differs from the kernel slab allocator in two primary
>>> +ways to achieve these design goals.
>>> +
>>> +zsmalloc never requires high order page allocations to back
>>> +slabs, or "size classes" in zsmalloc terms. Instead it allows
>>> +multiple single-order pages to be stitched together into a
>>> +"zspage" which backs the slab.  This allows for higher allocation
>>> +success rate under memory pressure.
>>> +
>>> +Also, zsmalloc allows objects to span page boundaries within the
>>> +zspage.  This allows for lower fragmentation than could be had
>>> +with the kernel slab allocator for objects between PAGE_SIZE/2
>>> +and PAGE_SIZE.  With the kernel slab allocator, if a page compresses
>>> +to 60% of it original size, the memory savings gained through
>>> +compression is lost in fragmentation because another object of
>>> +the same size can't be stored in the leftover space.
>>> +
>>> +This ability to span pages results in zsmalloc allocations not being
>>> +directly addressable by the user.  The user is given an
>>> +non-dereferencable handle in response to an allocation request.
>>> +That handle must be mapped, using zs_map_object(), which returns
>>> +a pointer to the mapped region that can be used.  The mapping is
>>> +necessary since the object data may reside in two different
>>> +noncontigious pages.
>> Do you mean the reason of  to use a zsmalloc object must map after
>> malloc is object data maybe reside in two different nocontiguous pages?
> Yes, that is one reason for the mapping.  The other reason (more of an
> added bonus) is below.
>
>>> +
>>> +For 32-bit systems, zsmalloc has the added benefit of being
>>> +able to back slabs with HIGHMEM pages, something not possible
>> What's the meaning of "back slabs with HIGHMEM pages"?
> By HIGHMEM, I'm referring to the HIGHMEM memory zone on 32-bit systems
> with larger that 1GB (actually a little less) of RAM.  The upper 3GB
> of the 4GB address space, depending on kernel build options, is not
> directly addressable by the kernel, but can be mapped into the kernel
> address space with functions like kmap() or kmap_atomic().
>
> These pages can't be used by slab/slub because they are not
> continuously mapped into the kernel address space.  However, since
> zsmalloc requires a mapping anyway to handle objects that span
> non-contiguous page boundaries, we do the kernel mapping as part of
> the process.
>
> So zspages, the conceptual slab in zsmalloc backed by single-order
> pages can include pages from the HIGHMEM zone as well.

Thanks for your clarify, http://lwn.net/Articles/537422/, your article 
about zswap in lwn.
"Additionally, the kernel slab allocator does not allow objects that are 
less than a page in size to span a page boundary. This means that if an 
object is PAGE_SIZE/2 + 1 bytes in size, it effectively use an entire 
page, resulting in ~50% waste. Hense there are *no kmalloc() cache size* 
between PAGE_SIZE/2 and PAGE_SIZE."
Are your sure? It seems that kmalloc cache support big size, your can 
check in include/linux/kmalloc_sizes.h

>
> Seth
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--------------080107040006080304030209
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <div class="moz-cite-prefix">On 02/19/2013 03:16 AM, Seth Jennings
      wrote:<br>
    </div>
    <blockquote cite="mid:51227DF4.9020900@linux.vnet.ibm.com"
      type="cite">
      <pre wrap="">On 02/16/2013 12:21 AM, Ric Mason wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">On 02/14/2013 02:38 AM, Seth Jennings wrote:
</pre>
        <blockquote type="cite">
          <pre wrap="">This patch adds a documentation file for zsmalloc at
Documentation/vm/zsmalloc.txt

Signed-off-by: Seth Jennings <a class="moz-txt-link-rfc2396E" href="mailto:sjenning@linux.vnet.ibm.com">&lt;sjenning@linux.vnet.ibm.com&gt;</a>
---
  Documentation/vm/zsmalloc.txt |   68
+++++++++++++++++++++++++++++++++++++++++
  1 file changed, 68 insertions(+)
  create mode 100644 Documentation/vm/zsmalloc.txt

diff --git a/Documentation/vm/zsmalloc.txt
b/Documentation/vm/zsmalloc.txt
new file mode 100644
index 0000000..85aa617
--- /dev/null
+++ b/Documentation/vm/zsmalloc.txt
@@ -0,0 +1,68 @@
+zsmalloc Memory Allocator
+
+Overview
+
+zmalloc a new slab-based memory allocator,
+zsmalloc, for storing compressed pages.  It is designed for
+low fragmentation and high allocation success rate on
+large object, but &lt;= PAGE_SIZE allocations.
+
+zsmalloc differs from the kernel slab allocator in two primary
+ways to achieve these design goals.
+
+zsmalloc never requires high order page allocations to back
+slabs, or "size classes" in zsmalloc terms. Instead it allows
+multiple single-order pages to be stitched together into a
+"zspage" which backs the slab.  This allows for higher allocation
+success rate under memory pressure.
+
+Also, zsmalloc allows objects to span page boundaries within the
+zspage.  This allows for lower fragmentation than could be had
+with the kernel slab allocator for objects between PAGE_SIZE/2
+and PAGE_SIZE.  With the kernel slab allocator, if a page compresses
+to 60% of it original size, the memory savings gained through
+compression is lost in fragmentation because another object of
+the same size can't be stored in the leftover space.
+
+This ability to span pages results in zsmalloc allocations not being
+directly addressable by the user.  The user is given an
+non-dereferencable handle in response to an allocation request.
+That handle must be mapped, using zs_map_object(), which returns
+a pointer to the mapped region that can be used.  The mapping is
+necessary since the object data may reside in two different
+noncontigious pages.
</pre>
        </blockquote>
        <pre wrap="">
Do you mean the reason of  to use a zsmalloc object must map after
malloc is object data maybe reside in two different nocontiguous pages?
</pre>
      </blockquote>
      <pre wrap="">
Yes, that is one reason for the mapping.  The other reason (more of an
added bonus) is below.

</pre>
      <blockquote type="cite">
        <pre wrap="">
</pre>
        <blockquote type="cite">
          <pre wrap="">+
+For 32-bit systems, zsmalloc has the added benefit of being
+able to back slabs with HIGHMEM pages, something not possible
</pre>
        </blockquote>
        <pre wrap="">
What's the meaning of "back slabs with HIGHMEM pages"?
</pre>
      </blockquote>
      <pre wrap="">
By HIGHMEM, I'm referring to the HIGHMEM memory zone on 32-bit systems
with larger that 1GB (actually a little less) of RAM.  The upper 3GB
of the 4GB address space, depending on kernel build options, is not
directly addressable by the kernel, but can be mapped into the kernel
address space with functions like kmap() or kmap_atomic().

These pages can't be used by slab/slub because they are not
continuously mapped into the kernel address space.  However, since
zsmalloc requires a mapping anyway to handle objects that span
non-contiguous page boundaries, we do the kernel mapping as part of
the process.

So zspages, the conceptual slab in zsmalloc backed by single-order
pages can include pages from the HIGHMEM zone as well.</pre>
    </blockquote>
    <br>
    Thanks for your clarify,
    <meta http-equiv="content-type" content="text/html;
      charset=ISO-8859-1">
    <a href="http://lwn.net/Articles/537422/">http://lwn.net/Articles/537422/</a>,
    your article about zswap in lwn.<br>
    <meta http-equiv="content-type" content="text/html;
      charset=ISO-8859-1">
    "Additionally, the kernel slab allocator does not allow objects that
    are less than a page in size to span a page boundary. This means
    that if an object is PAGE_SIZE/2 + 1 bytes in size, it effectively
    use an entire page, resulting in ~50% waste. Hense there are *no
    kmalloc() cache size* between PAGE_SIZE/2 and PAGE_SIZE."<br>
    Are your sure? It seems that kmalloc cache support big size, your
    can check in include/linux/kmalloc_sizes.h<br>
    <br>
    <blockquote cite="mid:51227DF4.9020900@linux.vnet.ibm.com"
      type="cite">
      <pre wrap="">

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to <a class="moz-txt-link-abbreviated" href="mailto:majordomo@kvack.org">majordomo@kvack.org</a>.  For more info on Linux MM,
see: <a class="moz-txt-link-freetext" href="http://www.linux-mm.org/">http://www.linux-mm.org/</a> .
Don't email: &lt;a href=mailto:<a class="moz-txt-link-rfc2396E" href="mailto:dont@kvack.org">"dont@kvack.org"</a>&gt; <a class="moz-txt-link-abbreviated" href="mailto:email@kvack.org">email@kvack.org</a> &lt;/a&gt;
</pre>
    </blockquote>
    <br>
  </body>
</html>

--------------080107040006080304030209--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
