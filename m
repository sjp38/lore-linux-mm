Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 323FD6B0270
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 16:36:12 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id z143so245128473ywz.7
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 13:36:12 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id i186si5532200ywb.122.2017.01.24.13.36.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 13:36:11 -0800 (PST)
Subject: Re: [PATCH 0/3] 1G transparent hugepage support for device dax
References: <148521477073.31533.17781371321988910714.stgit@djiang5-desk3.ch.intel.com>
 <20170124111248.GC20153@quack2.suse.cz>
 <CAPcyv4gW7cho=eE4BQZQ69J7ehREurP6CPbQX3z6eW7BUVT3Bw@mail.gmail.com>
 <20170124212435.GA23874@char.us.oracle.com>
From: Nilesh Choudhury <nilesh.choudhury@oracle.com>
Message-ID: <db42a11a-77ca-2caf-a13a-fb404d0ad2a1@oracle.com>
Date: Tue, 24 Jan 2017 13:35:55 -0800
MIME-Version: 1.0
In-Reply-To: <20170124212435.GA23874@char.us.oracle.com>
Content-Type: multipart/alternative;
 boundary="------------203F214388D2FC21902D1E8F"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, Dave Hansen <dave.hansen@linux.intel.com>, Linux MM <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

This is a multi-part message in MIME format.
--------------203F214388D2FC21902D1E8F
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

Konrad's explanation is precise.

There are applications which have a process model; and if you assume 
10,000 processes attempting to mmap all the 6TB memory available on a 
server; we are looking at the following:

    processes         ; 10,000
    memory            :    6TB
    pte @ 4k page size: 8 bytes / 4K of memory * #processes = 6TB / 4k * 8 * 10000 = 1.5GB * 80000 = 120,000GB
    pmd @ 2M page size: 120,000 / 512 = ~240GB
    pud @ 1G page size: 240GB / 512 = ~480MB

As you can see with 2M pages, this system will use up an exorbitant 
amount of DRAM to hold the page tables; but the 1G pages finally brings 
it down to a reasonable level.
Memory sizes will keep increasing; so this number will keep increasing.
An argument can be made to convert the applications from process model 
to thread model, but in the real world that may not be always practical.
Hopefully this helps explain the use case where this is valuable.

- Nilesh

On 1/24/2017 1:24 PM, Konrad Rzeszutek Wilk wrote:
> On Tue, Jan 24, 2017 at 10:26:54AM -0800, Dan Williams wrote:
>> On Tue, Jan 24, 2017 at 3:12 AM, Jan Kara <jack@suse.cz> wrote:
>>> On Mon 23-01-17 16:47:18, Dave Jiang wrote:
>>>> The following series implements support for 1G trasparent hugepage on
>>>> x86 for device dax. The bulk of the code was written by Mathew Wilcox
>>>> a while back supporting transparent 1G hugepage for fs DAX. I have
>>>> forward ported the relevant bits to 4.10-rc. The current submission has
>>>> only the necessary code to support device DAX.
>>> Well, you should really explain why do we want this functionality... Is
>>> anybody going to use it? Why would he want to and what will he gain by
>>> doing so? Because so far I haven't heard of a convincing usecase.
>>>
>> So the motivation and intended user of this functionality mirrors the
>> motivation and users of 1GB page support in hugetlbfs. Given expected
>> capacities of persistent memory devices an in-memory database may want
>> to reduce tlb pressure beyond what they can already achieve with 2MB
>> mappings of a device-dax file. We have customer feedback to that
>> effect as Willy mentioned in his previous version of these patches
>> [1].
> CCing Nilesh who may be able to shed some more light on this.
>
>> [1]: https://lkml.org/lkml/2016/1/31/52
>> _______________________________________________
>> Linux-nvdimm mailing list
>> Linux-nvdimm@lists.01.org
>> https://lists.01.org/mailman/listinfo/linux-nvdimm


--------------203F214388D2FC21902D1E8F
Content-Type: text/html; charset=windows-1252
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=windows-1252"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <p>Konrad's explanation is precise. <br>
    </p>
    <p>There are applications which have a process model; and if you
      assume 10,000 processes attempting to mmap all the 6TB memory
      available on a server; we are looking at the following:</p>
    <blockquote>
      <pre>processes         ; 10,000
memory            :    6TB
pte @ 4k page size: 8 bytes / 4K of memory * #processes = 6TB / 4k * 8 * 10000 = 1.5GB * 80000 = 120,000GB
pmd @ 2M page size: 120,000 / 512 = ~240GB
pud @ 1G page size: 240GB / 512 = ~480MB</pre>
    </blockquote>
    As you can see with 2M pages, this system will use up an exorbitant
    amount of DRAM to hold the page tables; but the 1G pages finally
    brings it down to a reasonable level.<br>
    Memory sizes will keep increasing; so this number will keep
    increasing.<br>
    An argument can be made to convert the applications from process
    model to thread model, but in the real world that may not be always
    practical.<br>
    Hopefully this helps explain the use case where this is valuable.<br>
    <br>
    - Nilesh<br>
    <br>
    <div class="moz-cite-prefix">On 1/24/2017 1:24 PM, Konrad Rzeszutek
      Wilk wrote:<br>
    </div>
    <blockquote cite="mid:20170124212435.GA23874@char.us.oracle.com"
      type="cite">
      <pre wrap="">On Tue, Jan 24, 2017 at 10:26:54AM -0800, Dan Williams wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">On Tue, Jan 24, 2017 at 3:12 AM, Jan Kara <a class="moz-txt-link-rfc2396E" href="mailto:jack@suse.cz">&lt;jack@suse.cz&gt;</a> wrote:
</pre>
        <blockquote type="cite">
          <pre wrap="">On Mon 23-01-17 16:47:18, Dave Jiang wrote:
</pre>
          <blockquote type="cite">
            <pre wrap="">The following series implements support for 1G trasparent hugepage on
x86 for device dax. The bulk of the code was written by Mathew Wilcox
a while back supporting transparent 1G hugepage for fs DAX. I have
forward ported the relevant bits to 4.10-rc. The current submission has
only the necessary code to support device DAX.
</pre>
          </blockquote>
          <pre wrap="">
Well, you should really explain why do we want this functionality... Is
anybody going to use it? Why would he want to and what will he gain by
doing so? Because so far I haven't heard of a convincing usecase.

</pre>
        </blockquote>
        <pre wrap="">
So the motivation and intended user of this functionality mirrors the
motivation and users of 1GB page support in hugetlbfs. Given expected
capacities of persistent memory devices an in-memory database may want
to reduce tlb pressure beyond what they can already achieve with 2MB
mappings of a device-dax file. We have customer feedback to that
effect as Willy mentioned in his previous version of these patches
[1].
</pre>
      </blockquote>
      <pre wrap="">
CCing Nilesh who may be able to shed some more light on this.

</pre>
      <blockquote type="cite">
        <pre wrap="">
[1]: <a class="moz-txt-link-freetext" href="https://lkml.org/lkml/2016/1/31/52">https://lkml.org/lkml/2016/1/31/52</a>
_______________________________________________
Linux-nvdimm mailing list
<a class="moz-txt-link-abbreviated" href="mailto:Linux-nvdimm@lists.01.org">Linux-nvdimm@lists.01.org</a>
<a class="moz-txt-link-freetext" href="https://lists.01.org/mailman/listinfo/linux-nvdimm">https://lists.01.org/mailman/listinfo/linux-nvdimm</a>
</pre>
      </blockquote>
    </blockquote>
    <br>
  </body>
</html>

--------------203F214388D2FC21902D1E8F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
