Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 1A28E6B0062
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 05:00:28 -0500 (EST)
Received: by mail-ia0-f169.google.com with SMTP id r4so6100731iaj.14
        for <linux-mm@kvack.org>; Wed, 21 Nov 2012 02:00:27 -0800 (PST)
Message-ID: <50ACA634.5000007@gmail.com>
Date: Wed, 21 Nov 2012 18:00:20 +0800
From: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
MIME-Version: 1.0
Subject: Re: Problem in Page Cache Replacement
References: <1353433362.85184.YahooMailNeo@web141101.mail.bf1.yahoo.com> <20121120182500.GH1408@quack.suse.cz> <1353485020.53500.YahooMailNeo@web141104.mail.bf1.yahoo.com> <1353485630.17455.YahooMailNeo@web141106.mail.bf1.yahoo.com> <50AC9220.70202@gmail.com> <20121121090204.GA9064@localhost> <50ACA209.9000101@gmail.com> <1353491880.11679.YahooMailNeo@web141102.mail.bf1.yahoo.com>
In-Reply-To: <1353491880.11679.YahooMailNeo@web141102.mail.bf1.yahoo.com>
Content-Type: multipart/alternative;
 boundary="------------000701020503000208040701"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: metin d <metdos@yahoo.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, =?UTF-8?B?TWV0aW4gRMO2xZ9sw7w=?= <metindoslu@gmail.com>

This is a multi-part message in MIME format.
--------------000701020503000208040701
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 11/21/2012 05:58 PM, metin d wrote:
> Hi Fengguang,
>
> I run tests and attached the results. The line below I guess shows the 
> data-1 page caches.
>
> 0x000000080000006c 6584051    25718  
> __RU_lA___________________P________ referenced,uptodate,lru,active,private

I thinks this is just one state of page cache pages.

>
> Metin
>
>
> ----- Original Message -----
> From: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
> To: Fengguang Wu <fengguang.wu@intel.com>
> Cc: metin d <metdos@yahoo.com>; Jan Kara <jack@suse.cz>; 
> "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>; 
> "linux-mm@kvack.org" <linux-mm@kvack.org>
> Sent: Wednesday, November 21, 2012 11:42 AM
> Subject: Re: Problem in Page Cache Replacement
>
> On 11/21/2012 05:02 PM, Fengguang Wu wrote:
> > On Wed, Nov 21, 2012 at 04:34:40PM +0800, Jaegeuk Hanse wrote:
> >> Cc Fengguang Wu.
> >>
> >> On 11/21/2012 04:13 PM, metin d wrote:
> >>>>    Curious. Added linux-mm list to CC to catch more attention. If 
> you run
> >>>> echo 1 >/proc/sys/vm/drop_caches does it evict data-1 pages from 
> memory?
> >>> I'm guessing it'd evict the entries, but am wondering if we could 
> run any more diagnostics before trying this.
> >>>
> >>> We regularly use a setup where we have two databases; one gets 
> used frequently and the other one about once a month. It seems like 
> the memory manager keeps unused pages in memory at the expense of 
> frequently used database's performance.
> >>> My understanding was that under memory pressure from heavily
> >>> accessed pages, unused pages would eventually get evicted. Is there
> >>> anything else we can try on this host to understand why this is
> >>> happening?
> > We may debug it this way.
> >
> > 1) run 'fadvise data-2 0 0 dontneed' to drop data-2 cached pages
> >    (please double check via /proc/vmstat whether it does the 
> expected work)
> >
> > 2) run 'page-types -r' with root, to view the page status for the
> >    remaining pages of data-1
> >
> > The fadvise tool comes from Andrew Morton's ext3-tools. (source code 
> attached)
> > Please compile them with options "-Dlinux -I. -D_GNU_SOURCE 
> -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE"
> >
> > page-types can be found in the kernel source tree tools/vm/page-types.c
> >
> > Sorry that sounds a bit twisted.. I do have a patch to directly dump
> > page cache status of a user specified file, however it's not
> > upstreamed yet.
>
> Hi Fengguang,
>
> Thanks for you detail steps, I think metin can have a try.
>
>         flags    page-count      MB  symbolic-flags long-symbolic-flags
> 0x0000000000000000        607699    2373
> ___________________________________
> 0x0000000100000000        343227    1340
> _______________________r___________    reserved
>
> But I have some questions of the print of page-type:
>
> Is 2373MB here mean total memory in used include page cache? I don't
> think so.
> Which kind of pages will be marked reserved?
> Which line of long-symbolic-flags is for page cache?
>
> Regards,
> Jaegeuk
>
> >
> > Thanks,
> > Fengguang
> >
> >>> On Tue 20-11-12 09:42:42, metin d wrote:
> >>>> I have two PostgreSQL databases named data-1 and data-2 that sit 
> on the
> >>>> same machine. Both databases keep 40 GB of data, and the total memory
> >>>> available on the machine is 68GB.
> >>>>
> >>>> I started data-1 and data-2, and ran several queries to go over 
> all their
> >>>> data. Then, I shut down data-1 and kept issuing queries against 
> data-2.
> >>>> For some reason, the OS still holds on to large parts of data-1's 
> pages
> >>>> in its page cache, and reserves about 35 GB of RAM to data-2's 
> files. As
> >>>> a result, my queries on data-2 keep hitting disk.
> >>>>
> >>>> I'm checking page cache usage with fincore. When I run a table 
> scan query
> >>>> against data-2, I see that data-2's pages get evicted and put 
> back into
> >>>> the cache in a round-robin manner. Nothing happens to data-1's pages,
> >>>> although they haven't been touched for days.
> >>>>
> >>>> Does anybody know why data-1's pages aren't evicted from the page 
> cache?
> >>>> I'm open to all kind of suggestions you think it might relate to 
> problem.
> >>>    Curious. Added linux-mm list to CC to catch more attention. If 
> you run
> >>> echo 1 >/proc/sys/vm/drop_caches
> >>>    does it evict data-1 pages from memory?
> >>>
> >>>> This is an EC2 m2.4xlarge instance on Amazon with 68 GB of RAM and no
> >>>> swap space. The kernel version is:
> >>>>
> >>>> $ uname -r
> >>>> 3.2.28-45.62.amzn1.x86_64
> >>>> Edit:
> >>>>
> >>>> and it seems that I use one NUMA instance, if  you think that it 
> can a problem.
> >>>>
> >>>> $ numactl --hardware
> >>>> available: 1 nodes (0)
> >>>> node 0 cpus: 0 1 2 3 4 5 6 7
> >>>> node 0 size: 70007 MB
> >>>> node 0 free: 360 MB
> >>>> node distances:
> >>>> node  0
> >>>>    0:  10
>


--------------000701020503000208040701
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta content="text/html; charset=UTF-8" http-equiv="Content-Type">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <div class="moz-cite-prefix">On 11/21/2012 05:58 PM, metin d wrote:<br>
    </div>
    <blockquote
      cite="mid:1353491880.11679.YahooMailNeo@web141102.mail.bf1.yahoo.com"
      type="cite">
      <div style="color:#000; background-color:#fff; font-family:times
        new roman, new york, times, serif;font-size:12pt">
        <div><span>Hi </span>Fengguang,</div>
        <div style="color: rgb(0, 0, 0); font-size: 13.3333px;
          font-family: arial,helvetica,sans-serif; background-color:
          transparent; font-style: normal;"><br>
        </div>
        <div style="color: rgb(0, 0, 0); font-size: 13.3333px;
          font-family: arial,helvetica,sans-serif; background-color:
          transparent; font-style: normal;">I run tests and attached the
          results. The line below I guess shows the data-1 page caches.</div>
        <div style="color: rgb(0, 0, 0); font-size: 13.3333px;
          font-family: arial,helvetica,sans-serif; background-color:
          transparent; font-style: normal;"><br>
        </div>
        <div style="color: rgb(0, 0, 0); font-size: 13.3333px;
          font-family: arial,helvetica,sans-serif; background-color:
          transparent; font-style: normal;">0x000000080000006cA A A  A A 
          6584051A A A  25718A  __RU_lA___________________P________A A A 
          referenced,uptodate,lru,active,private</div>
      </div>
    </blockquote>
    <br>
    I thinks this is just one state of page cache pages.<br>
    <br>
    <blockquote
      cite="mid:1353491880.11679.YahooMailNeo@web141102.mail.bf1.yahoo.com"
      type="cite">
      <div style="color:#000; background-color:#fff; font-family:times
        new roman, new york, times, serif;font-size:12pt">
        <div style="color: rgb(0, 0, 0); font-size: 13.3333px;
          font-family: arial,helvetica,sans-serif; background-color:
          transparent; font-style: normal;"><br>
        </div>
        <div style="color: rgb(0, 0, 0); font-size: 13.3333px;
          font-family: arial,helvetica,sans-serif; background-color:
          transparent; font-style: normal;">Metin<br>
        </div>
        <div style="color: rgb(0, 0, 0); font-size: 13.3333px;
          font-family: arial,helvetica,sans-serif; background-color:
          transparent; font-style: normal;"> <br>
        </div>
        <div> <br>
          <div>----- Original Message -----<br>
            From: Jaegeuk Hanse <a class="moz-txt-link-rfc2396E" href="mailto:jaegeuk.hanse@gmail.com">&lt;jaegeuk.hanse@gmail.com&gt;</a><br>
            To: Fengguang Wu <a class="moz-txt-link-rfc2396E" href="mailto:fengguang.wu@intel.com">&lt;fengguang.wu@intel.com&gt;</a><br>
            Cc: metin d <a class="moz-txt-link-rfc2396E" href="mailto:metdos@yahoo.com">&lt;metdos@yahoo.com&gt;</a>; Jan Kara
            <a class="moz-txt-link-rfc2396E" href="mailto:jack@suse.cz">&lt;jack@suse.cz&gt;</a>; <a class="moz-txt-link-rfc2396E" href="mailto:linux-kernel@vger.kernel.org">"linux-kernel@vger.kernel.org"</a>
            <a class="moz-txt-link-rfc2396E" href="mailto:linux-kernel@vger.kernel.org">&lt;linux-kernel@vger.kernel.org&gt;</a>; <a class="moz-txt-link-rfc2396E" href="mailto:linux-mm@kvack.org">"linux-mm@kvack.org"</a>
            <a class="moz-txt-link-rfc2396E" href="mailto:linux-mm@kvack.org">&lt;linux-mm@kvack.org&gt;</a><br>
            Sent: Wednesday, November 21, 2012 11:42 AM<br>
            Subject: Re: Problem in Page Cache Replacement<br>
            <br>
            On 11/21/2012 05:02 PM, Fengguang Wu wrote:<br>
            &gt; On Wed, Nov 21, 2012 at 04:34:40PM +0800, Jaegeuk Hanse
            wrote:<br>
            &gt;&gt; Cc Fengguang Wu.<br>
            &gt;&gt;<br>
            &gt;&gt; On 11/21/2012 04:13 PM, metin d wrote:<br>
            &gt;&gt;&gt;&gt;A  A  Curious. Added linux-mm list to CC to
            catch more attention. If you run<br>
            &gt;&gt;&gt;&gt; echo 1 &gt;/proc/sys/vm/drop_caches does it
            evict data-1 pages from memory?<br>
            &gt;&gt;&gt; I'm guessing it'd evict the entries, but am
            wondering if we could run any more diagnostics before trying
            this.<br>
            &gt;&gt;&gt;<br>
            &gt;&gt;&gt; We regularly use a setup where we have two
            databases; one gets used frequently and the other one about
            once a month. It seems like the memory manager keeps unused
            pages in memory at the expense of frequently used database's
            performance.<br>
            &gt;&gt;&gt; My understanding was that under memory pressure
            from heavily<br>
            &gt;&gt;&gt; accessed pages, unused pages would eventually
            get evicted. Is there<br>
            &gt;&gt;&gt; anything else we can try on this host to
            understand why this is<br>
            &gt;&gt;&gt; happening?<br>
            &gt; We may debug it this way.<br>
            &gt;<br>
            &gt; 1) run 'fadvise data-2 0 0 dontneed' to drop data-2
            cached pages<br>
            &gt;A  A  (please double check via /proc/vmstat whether it
            does the expected work)<br>
            &gt;<br>
            &gt; 2) run 'page-types -r' with root, to view the page
            status for the<br>
            &gt;A  A  remaining pages of data-1<br>
            &gt;<br>
            &gt; The fadvise tool comes from Andrew Morton's ext3-tools.
            (source code attached)<br>
            &gt; Please compile them with options "-Dlinux -I.
            -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE"<br>
            &gt;<br>
            &gt; page-types can be found in the kernel source tree
            tools/vm/page-types.c<br>
            &gt;<br>
            &gt; Sorry that sounds a bit twisted.. I do have a patch to
            directly dump<br>
            &gt; page cache status of a user specified file, however
            it's not<br>
            &gt; upstreamed yet.<br>
            <br>
            Hi Fengguang,<br>
            <br>
            Thanks for you detail steps, I think metin can have a try.<br>
            <br>
            A  A  A  A  flagsA  A  page-countA  A  A  MBA  symbolic-flags
            long-symbolic-flags<br>
            0x0000000000000000A  A  A  A  607699A  A  2373 <br>
            ___________________________________<br>
            0x0000000100000000A  A  A  A  343227A  A  1340 <br>
            _______________________r___________A  A  reserved<br>
            <br>
            But I have some questions of the print of page-type:<br>
            <br>
            Is 2373MB here mean total memory in used include page cache?
            I don't <br>
            think so.<br>
            Which kind of pages will be marked reserved?<br>
            Which line of long-symbolic-flags is for page cache?<br>
            <br>
            Regards,<br>
            Jaegeuk<br>
            <br>
            &gt;<br>
            &gt; Thanks,<br>
            &gt; Fengguang<br>
            &gt;<br>
            &gt;&gt;&gt; On Tue 20-11-12 09:42:42, metin d wrote:<br>
            &gt;&gt;&gt;&gt; I have two PostgreSQL databases named
            data-1 and data-2 that sit on the<br>
            &gt;&gt;&gt;&gt; same machine. Both databases keep 40 GB of
            data, and the total memory<br>
            &gt;&gt;&gt;&gt; available on the machine is 68GB.<br>
            &gt;&gt;&gt;&gt;<br>
            &gt;&gt;&gt;&gt; I started data-1 and data-2, and ran
            several queries to go over all their<br>
            &gt;&gt;&gt;&gt; data. Then, I shut down data-1 and kept
            issuing queries against data-2.<br>
            &gt;&gt;&gt;&gt; For some reason, the OS still holds on to
            large parts of data-1's pages<br>
            &gt;&gt;&gt;&gt; in its page cache, and reserves about 35 GB
            of RAM to data-2's files. As<br>
            &gt;&gt;&gt;&gt; a result, my queries on data-2 keep hitting
            disk.<br>
            &gt;&gt;&gt;&gt;<br>
            &gt;&gt;&gt;&gt; I'm checking page cache usage with fincore.
            When I run a table scan query<br>
            &gt;&gt;&gt;&gt; against data-2, I see that data-2's pages
            get evicted and put back into<br>
            &gt;&gt;&gt;&gt; the cache in a round-robin manner. Nothing
            happens to data-1's pages,<br>
            &gt;&gt;&gt;&gt; although they haven't been touched for
            days.<br>
            &gt;&gt;&gt;&gt;<br>
            &gt;&gt;&gt;&gt; Does anybody know why data-1's pages aren't
            evicted from the page cache?<br>
            &gt;&gt;&gt;&gt; I'm open to all kind of suggestions you
            think it might relate to problem.<br>
            &gt;&gt;&gt;A  A  Curious. Added linux-mm list to CC to catch
            more attention. If you run<br>
            &gt;&gt;&gt; echo 1 &gt;/proc/sys/vm/drop_caches<br>
            &gt;&gt;&gt;A  A  does it evict data-1 pages from memory?<br>
            &gt;&gt;&gt;<br>
            &gt;&gt;&gt;&gt; This is an EC2 m2.4xlarge instance on
            Amazon with 68 GB of RAM and no<br>
            &gt;&gt;&gt;&gt; swap space. The kernel version is:<br>
            &gt;&gt;&gt;&gt;<br>
            &gt;&gt;&gt;&gt; $ uname -r<br>
            &gt;&gt;&gt;&gt; 3.2.28-45.62.amzn1.x86_64<br>
            &gt;&gt;&gt;&gt; Edit:<br>
            &gt;&gt;&gt;&gt;<br>
            &gt;&gt;&gt;&gt; and it seems that I use one NUMA instance,
            ifA  you think that it can a problem.<br>
            &gt;&gt;&gt;&gt;<br>
            &gt;&gt;&gt;&gt; $ numactl --hardware<br>
            &gt;&gt;&gt;&gt; available: 1 nodes (0)<br>
            &gt;&gt;&gt;&gt; node 0 cpus: 0 1 2 3 4 5 6 7<br>
            &gt;&gt;&gt;&gt; node 0 size: 70007 MB<br>
            &gt;&gt;&gt;&gt; node 0 free: 360 MB<br>
            &gt;&gt;&gt;&gt; node distances:<br>
            &gt;&gt;&gt;&gt; nodeA  0<br>
            &gt;&gt;&gt;&gt;A  A  0:A  10<br>
            <br>
          </div>
        </div>
      </div>
    </blockquote>
    <br>
  </body>
</html>

--------------000701020503000208040701--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
