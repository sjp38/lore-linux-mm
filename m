Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id CDC896B0002
	for <linux-mm@kvack.org>; Sun, 10 Feb 2013 02:55:55 -0500 (EST)
Message-ID: <51175251.3040209@mellanox.com>
Date: Sun, 10 Feb 2013 09:54:57 +0200
From: Shachar Raindel <raindel@mellanox.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC] Hardware initiated paging of user process pages,
 hardware access to the CPU page tables of user processes
References: <5114DF05.7070702@mellanox.com> <CANN689Ff6vSu4ZvHek4J4EMzFG7EjF-Ej48hJKV_4SrLoj+mCA@mail.gmail.com>
In-Reply-To: <CANN689Ff6vSu4ZvHek4J4EMzFG7EjF-Ej48hJKV_4SrLoj+mCA@mail.gmail.com>
Content-Type: multipart/alternative;
	boundary="------------020209080104080609050500"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Roland Dreier <roland@purestorage.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Liran Liss <liranl@mellanox.com>

--------------020209080104080609050500
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

On 2/9/2013 8:05 AM, Michel Lespinasse wrote:
> On Fri, Feb 8, 2013 at 3:18 AM, Shachar Raindel<raindel@mellanox.com>  wrote:
>> Hi,
>>
>> We would like to present a reference implementation for safely sharing
>> memory pages from user space with the hardware, without pinning.
>>
>> We will be happy to hear the community feedback on our prototype
>> implementation, and suggestions for future improvements.
>>
>> We would also like to discuss adding features to the core MM subsystem to
>> assist hardware access to user memory without pinning.
> This sounds kinda scary TBH; however I do understand the need for such
> technology.
The technological challenges here are actually rather similar to the 
ones experienced
by hypervisors that want to allow swapping of virtual machines. As a 
result, we benefit
greatly from the mmu notifiers implemented for KVM. Reading the page 
table directly
will be another level of challenge.
> I think one issue is that many MM developers are insufficiently aware
> of such developments; having a technology presentation would probably
> help there; but traditionally LSF/MM sessions are more interactive
> between developers who are already quite familiar with the technology.
> I think it would help if you could send in advance a detailed
> presentation of the problem and the proposed solutions (and then what
> they require of the MM layer) so people can be better prepared.
We hope to send out an RFC patch-set of the feature implementation for 
our hardware
soon, which might help to demonstrate a use case for the technology.

The current programming model for InfiniBand (and related network 
protocols - RoCE,
iWarp) relies on the user space program registering memory regions for 
use with the
hardware. Upon registration, the driver performs pinning 
(get_user_pages) of the
memory area, updates a mapping table in the hardware and provides the user
application with a handle for the mapping. The user space application 
then use this
handle to request the hardware to access this area for network IO.

While achieving unbeatable IO performance (round-trip latency, for user 
space programs,
of less than 2  microseconds, bandwidth of 56 Gbit/second), this model 
is relatively
hard to use:

- The need for explicit memory registration for each area makes the API 
rather
   complex to use. Ideal API would have a handle per process, that 
allows it to
   communicate with the hardware using the process virtual addresses.

- After a part of the address space has been registered, the application 
must be
   careful not to move the pages around. For example, doing a fork 
results in all of
   the memory registrations pointing to the wrong pages (which is very 
hard to debug).
   This was partially addressed at [1], but the cure is nearly as bad as 
the disease - when
   MADVISE_DONTFORK is used on the heap, a simple call to malloc in the 
child process
   might crash the process.

- Memory which was registered is not swappable. As a result, one cannot 
write
   applications that overcommit for physical memory while using this 
API. Similarly to
   what Jerome described about GPU applications, for network access the 
application
   might want to use ~10% of its allocated memory space, but it is 
required to either
   pin all of the memory, use heuristics to predict what memory will be 
used or
   perform expensive copying/pinning for every network transaction. All 
of these are
   non-optimal.

> And first I'd like to ask, aren't IOMMUs supposed to already largely
> solve this problem ? (probably a dumb question, but that just tells
> you how much you need to explain :)
>

IOMMU v1 doesn't solve this problem, as it gives you only one mapping 
table per
PCI function. If you want ~64 processes on your machine to be able to 
access the
network, this is not nearly enough. It is helping in implementing PCI 
pass-thru for
virtualized guests (with the hardware devices exposing several virtual 
PCI functions
for the guests), but that is still not enough for user space applications.

To some extant, IOMMU v1 might even be an obstacle to implementing such
feature, as it prevents PCI devices from accessing parts of the memory, 
requiring
driver intervention for every page fault, even if the page is in memory.

IOMMU v2 [2] is a step at the same direction that we are moving towards, 
offering
PASID - a unique identifier for each transaction that the device 
performs, allowing
to associate the transaction with a specific process. However, the 
challenges there
are similar to these we encounter when using an address translation 
table on the
PCI device itself (NIC/GPU).

References:

1. MADVISE_DONTFORK - http://lwn.net/Articles/171956/
2. AMD IOMMU v2 - 
http://www.linux-kvm.org/wiki/images/b/b1/2011-forum-amd-iommuv2-kvm.pdf


--------------020209080104080609050500
Content-Type: text/html; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    On 2/9/2013 8:05 AM, Michel Lespinasse wrote:
    <blockquote
cite="mid:CANN689Ff6vSu4ZvHek4J4EMzFG7EjF-Ej48hJKV_4SrLoj+mCA@mail.gmail.com"
      type="cite">
      <pre wrap="">On Fri, Feb 8, 2013 at 3:18 AM, Shachar Raindel <a class="moz-txt-link-rfc2396E" href="mailto:raindel@mellanox.com">&lt;raindel@mellanox.com&gt;</a> wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">Hi,

We would like to present a reference implementation for safely sharing
memory pages from user space with the hardware, without pinning.

We will be happy to hear the community feedback on our prototype
implementation, and suggestions for future improvements.

We would also like to discuss adding features to the core MM subsystem to
assist hardware access to user memory without pinning.
</pre>
      </blockquote>
      <pre wrap="">This sounds kinda scary TBH; however I do understand the need for such
technology.
</pre>
    </blockquote>
    The technological challenges here are actually rather similar to the
    ones experienced<br>
    by hypervisors that want to allow swapping of virtual machines. As a
    result, we benefit<br>
    greatly from the mmu notifiers implemented for KVM. Reading the page
    table directly<br>
    will be another level of challenge.<br>
    <blockquote
cite="mid:CANN689Ff6vSu4ZvHek4J4EMzFG7EjF-Ej48hJKV_4SrLoj+mCA@mail.gmail.com"
      type="cite">
      <pre wrap="">I think one issue is that many MM developers are insufficiently aware
of such developments; having a technology presentation would probably
help there; but traditionally LSF/MM sessions are more interactive
between developers who are already quite familiar with the technology.
I think it would help if you could send in advance a detailed
presentation of the problem and the proposed solutions (and then what
they require of the MM layer) so people can be better prepared.
</pre>
    </blockquote>
    We hope to send out an RFC patch-set of the feature implementation
    for our hardware<br>
    soon, which might help to demonstrate a use case for the technology.<br>
    <br>
    The current programming model for InfiniBand (and related network
    protocols - RoCE,<br>
    iWarp) relies on the user space program registering memory regions
    for use with the<br>
    hardware. Upon registration, the driver performs pinning
    (get_user_pages) of the<br>
    memory area, updates a mapping table in the hardware and provides
    the user <br>
    application with a handle for the mapping. The user space
    application then use this<br>
    handle to request the hardware to access this area for network IO.<br>
    <br>
    While achieving unbeatable IO performance (round-trip latency, for
    user space programs,<br>
    of less than 2&nbsp; microseconds, bandwidth of 56 Gbit/second), this
    model is relatively<br>
    hard to use:<br>
    <br>
    - The need for explicit memory registration for each area makes the
    API rather<br>
    &nbsp; complex to use. Ideal API would have a handle per process, that
    allows it to<br>
    &nbsp; communicate with the hardware using the process virtual addresses.<br>
    <br>
    - After a part of the address space has been registered, the
    application must be<br>
    &nbsp; careful not to move the pages around. For example, doing a fork
    results in all of <br>
    &nbsp; the memory registrations pointing to the wrong pages (which is
    very hard to debug). <br>
    &nbsp; This was partially addressed at [1], but the cure is nearly as bad
    as the disease - when <br>
    &nbsp; MADVISE_DONTFORK is used on the heap, a simple call to malloc in
    the child process<br>
    &nbsp; might crash the process.<br>
    <br>
    - Memory which was registered is not swappable. As a result, one
    cannot write <br>
    &nbsp; applications that overcommit for physical memory while using this
    API. Similarly to<br>
    &nbsp; what
    <meta http-equiv="Content-Type" content="text/html;
      charset=ISO-8859-1">
    <meta name="ProgId" content="Word.Document">
    <meta name="Generator" content="Microsoft Word 14">
    <meta name="Originator" content="Microsoft Word 14">
    <link rel="File-List"
href="file:///C:%5CUsers%5Craindel%5CAppData%5CLocal%5CTemp%5Cmsohtmlclip1%5C01%5Cclip_filelist.xml">
    <link rel="themeData"
href="file:///C:%5CUsers%5Craindel%5CAppData%5CLocal%5CTemp%5Cmsohtmlclip1%5C01%5Cclip_themedata.thmx">
    <link rel="colorSchemeMapping"
href="file:///C:%5CUsers%5Craindel%5CAppData%5CLocal%5CTemp%5Cmsohtmlclip1%5C01%5Cclip_colorschememapping.xml">
    <style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:-536870145 1073786111 1 0 415 0;}
@font-face
	{font-family:Consolas;
	panose-1:2 11 6 9 2 2 4 3 2 4;
	mso-font-charset:0;
	mso-generic-font-family:modern;
	mso-font-pitch:fixed;
	mso-font-signature:-520092929 1073806591 9 0 415 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-unhide:no;
	mso-style-qformat:yes;
	mso-style-parent:"";
	margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";
	mso-ascii-font-family:Calibri;
	mso-ascii-theme-font:minor-latin;
	mso-fareast-font-family:Calibri;
	mso-fareast-theme-font:minor-latin;
	mso-hansi-font-family:Calibri;
	mso-hansi-theme-font:minor-latin;
	mso-bidi-font-family:Arial;
	mso-bidi-theme-font:minor-bidi;}
p.MsoPlainText, li.MsoPlainText, div.MsoPlainText
	{mso-style-noshow:yes;
	mso-style-priority:99;
	mso-style-link:"Plain Text Char";
	margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	mso-bidi-font-size:10.5pt;
	font-family:"Calibri","sans-serif";
	mso-fareast-font-family:Calibri;
	mso-fareast-theme-font:minor-latin;
	mso-bidi-font-family:Consolas;}
span.PlainTextChar
	{mso-style-name:"Plain Text Char";
	mso-style-noshow:yes;
	mso-style-priority:99;
	mso-style-unhide:no;
	mso-style-locked:yes;
	mso-style-link:"Plain Text";
	mso-bidi-font-size:10.5pt;
	font-family:"Calibri","sans-serif";
	mso-ascii-font-family:Calibri;
	mso-hansi-font-family:Calibri;
	mso-bidi-font-family:Consolas;}
.MsoChpDefault
	{mso-style-type:export-only;
	mso-default-props:yes;
	font-family:"Calibri","sans-serif";
	mso-ascii-font-family:Calibri;
	mso-ascii-theme-font:minor-latin;
	mso-fareast-font-family:Calibri;
	mso-fareast-theme-font:minor-latin;
	mso-hansi-font-family:Calibri;
	mso-hansi-theme-font:minor-latin;
	mso-bidi-font-family:Arial;
	mso-bidi-theme-font:minor-bidi;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-paper-source:0;}
div.WordSection1
	{page:WordSection1;}
-->
</style>Jerome described about GPU applications, for network access the
    application<br>
    &nbsp; might want to use ~10% of its allocated memory space, but it is
    required to either<br>
    &nbsp; pin all of the memory, use heuristics to predict what memory will
    be used or<br>
    &nbsp; perform expensive copying/pinning for every network transaction.
    All of these are<br>
    &nbsp; non-optimal.<br>
    <br>
    <blockquote
cite="mid:CANN689Ff6vSu4ZvHek4J4EMzFG7EjF-Ej48hJKV_4SrLoj+mCA@mail.gmail.com"
      type="cite">
      <pre wrap="">And first I'd like to ask, aren't IOMMUs supposed to already largely
solve this problem ? (probably a dumb question, but that just tells
you how much you need to explain :)

</pre>
    </blockquote>
    <br>
    IOMMU v1 doesn't solve this problem, as it gives you only one
    mapping table per <br>
    PCI function. If you want ~64 processes on your machine to be able
    to access the<br>
    network, this is not nearly enough. It is helping in implementing
    PCI pass-thru for<br>
    virtualized guests (with the hardware devices exposing several
    virtual PCI functions<br>
    for the guests), but that is still not enough for user space
    applications.<br>
    <br>
    To some extant, IOMMU v1 might even be an obstacle to implementing
    such <br>
    feature, as it prevents PCI devices from accessing parts of the
    memory, requiring<br>
    driver intervention for every page fault, even if the page is in
    memory.<br>
    <br>
    IOMMU v2 [2] is a step at the same direction that we are moving
    towards, offering<br>
    PASID - a unique identifier for each transaction that the device
    performs, allowing<br>
    to associate the transaction with a specific process. However, the
    challenges there<br>
    are similar to these we encounter when using an address translation
    table on the<br>
    PCI device itself (NIC/GPU).<br>
    <br>
    References:<br>
    <br>
    1. MADVISE_DONTFORK - <a class="moz-txt-link-freetext"
      href="http://lwn.net/Articles/171956/">http://lwn.net/Articles/171956/</a><br>
    2. AMD IOMMU v2 - <a class="moz-txt-link-freetext"
href="http://www.linux-kvm.org/wiki/images/b/b1/2011-forum-amd-iommuv2-kvm.pdf">http://www.linux-kvm.org/wiki/images/b/b1/2011-forum-amd-iommuv2-kvm.pdf</a><br>
    <br>
  </body>
</html>

--------------020209080104080609050500--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
