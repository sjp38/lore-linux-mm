Received: from issun5.hti.com ([130.210.202.3]) by issun6.hti.com
          (Netscape Messaging Server 3.6)  with ESMTP id AAA70F6
          for <linux-mm@kvack.org>; Tue, 1 May 2001 12:02:08 -0500
Message-ID: <3AEEF265.9020209@link.com>
Date: Tue, 01 May 2001 13:29:09 -0400
From: "Richard F Weber" <rfweber@link.com>
MIME-Version: 1.0
Subject: Re: About reading /proc/*/mem
References: <Pine.GSO.4.21.0105011300110.9771-100000@weyl.math.psu.edu>
Content-Type: multipart/alternative;
 boundary="------------060405030505070503060705"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--------------060405030505070503060705
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Actually what we are looking to do is a lot more simplistic than that 
what you are suggesting.  The RT applications is the Host portion of a 
flight Sim.  So for example, we want to see what the system thinks it's 
current altitude is at, or what position the throttle is at, etc.  So 
there isn't a lot of dynamic list generation, or pointer manipulation 
going on.  Having dynamic data generation and/or pointers is another 
nasty hole that gets opened up that nobody here is quite ready to step into.

So the majority of the data is static, as well as small enough to be 
atomic.  Mostly 32-bit floats & ints with occaisional calls to 64-bit 
floats & ints. 

Don't forget too, that since this is running in a real-time environment, 
that alot of things are expected to be guaranteed.  We know a certain 
process is going to be running at 50 Hz, or 200Hz.  So when it's 
timeslice is complete it really better be done or else we have 
architecture problems.  The child will be getting interrupts & starting, 
running, & finishing 50 times a second, meanwhile, the debug process may 
be running at 1 Hzand updating relatively slowly.  Assuming this is a 
uniprocessor, the child process should be totally done running when the 
debug process goes in to get updates.  On an SMP there will probobally 
be some synchronization problems, but we'll worry about that when we get 
there.

What I'm trying to do is port an application that was working on Suns, 
SGI's & Concurrent PowerHawks over to Linux.  All three used the /proc 
to access the memory, and Linux doesn't seem to offer the same kind of 
support.  Which brings me back to my original question of how to tie 
into the process's memory without interrupting it's execution.

--Rich

Alexander Viro wrote:

>
>On Tue, 1 May 2001, Richard F Weber wrote:
>
>>See this is where I start seeming to have problems.  I can open 
>>/proc/*/mem & lseek, but reads come back as "No such process".  However, 
>>if I first do a ptrace(PTRACE_ATTACH), then I can read the data, but the 
>>process stops.  I've kind of dug through the sys_ptrace() code under 
>>/usr/src/linux/arch/i386/kernel/ptrace.c, and can see and understand 
>>generally what it's doing, but that's getting into serious kernel-land 
>>stuff.  I wouldn't expect it to be this difficult to just open up 
>>another processes /proc/*/mem file to read data from.
>>
>>Is there something obvious I'm missing?  It seems to keep pointing back 
>>to ptrace & /proc/*/mem are very closely related (ie: the same) 
>>including stopping of the child.
>>
>
>OK, here's something I really don't understand. Suppose that I tell your
>debugger to tell me when in the executed program foo becomes greater than
>bar[0] + 14. Or when cyclic list foo becomes longer than 1 element
>(i.e. foo.next != foo.prev).
>
>How do you do that if program is running? If you don't guarantee that
>it doesn't run during the access to its memory (moreover, between sever
>such accesses) - the data you get is worthless.
>


--------------060405030505070503060705
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<html><head></head><body>Actually what we are looking to do is a lot more
simplistic than that what you are suggesting.&nbsp; The RT applications is the
Host portion of a flight Sim.&nbsp; So for example, we want to see what the system
thinks it's current altitude is at, or what position the throttle is at,
etc.&nbsp; So there isn't a lot of dynamic list generation, or pointer manipulation
going on.&nbsp; Having dynamic data generation and/or pointers is another nasty
hole that gets opened up that nobody here is quite ready to step into.<br>
<br>
So the majority of the data is static, as well as small enough to be atomic.&nbsp;
Mostly 32-bit floats &amp; ints with occaisional calls to 64-bit floats &amp;
ints.&nbsp; <br>
<br>
 Don't forget too, that since this is running in a real-time environment,
that alot of things are expected to be guaranteed.&nbsp; We know a certain process
is going to be running at 50 Hz, or 200Hz.&nbsp; So when it's timeslice is complete
it really better be done or else we have architecture problems.&nbsp; The child
will be getting interrupts &amp; starting, running, &amp; finishing 50 times
a second, meanwhile, the debug process may be running at 1 Hzand updating
relatively slowly.&nbsp; Assuming this is a uniprocessor, the child process should
be totally done running when the debug process goes in to get updates.&nbsp; On
an SMP there will probobally be some synchronization problems, but we'll
worry about that when we get there.<br>
<br>
What I'm trying to do is port an application that was working on Suns, SGI's
&amp; Concurrent PowerHawks over to Linux.&nbsp; All three used the /proc to access
the memory, and Linux doesn't seem to offer the same kind of support.&nbsp; Which
brings me back to my original question of how to tie into the process's memory
without interrupting it's execution.<br>
<br>
--Rich<br>
<br>
Alexander Viro wrote:<br>
<blockquote type="cite" cite="mid:Pine.GSO.4.21.0105011300110.9771-100000@weyl.math.psu.edu"><pre wrap=""><br>On Tue, 1 May 2001, Richard F Weber wrote:<br><br></pre>
  <blockquote type="cite"><pre wrap="">See this is where I start seeming to have problems.  I can open <br>/proc/*/mem &amp; lseek, but reads come back as "No such process".  However, <br>if I first do a ptrace(PTRACE_ATTACH), then I can read the data, but the <br>process stops.  I've kind of dug through the sys_ptrace() code under <br>/usr/src/linux/arch/i386/kernel/ptrace.c, and can see and understand <br>generally what it's doing, but that's getting into serious kernel-land <br>stuff.  I wouldn't expect it to be this difficult to just open up <br>another processes /proc/*/mem file to read data from.<br></pre></blockquote>
    <blockquote type="cite"><pre wrap="">Is there something obvious I'm missing?  It seems to keep pointing back <br>to ptrace &amp; /proc/*/mem are very closely related (ie: the same) <br>including stopping of the child.<br></pre></blockquote>
      <pre wrap=""><!----><br>OK, here's something I really don't understand. Suppose that I tell your<br>debugger to tell me when in the executed program foo becomes greater than<br>bar[0] + 14. Or when cyclic list foo becomes longer than 1 element<br>(i.e. foo.next != foo.prev).<br><br>How do you do that if program is running? If you don't guarantee that<br>it doesn't run during the access to its memory (moreover, between sever<br>such accesses) - the data you get is worthless.<br><br></pre>
      </blockquote>
      <br>
</body></html>
--------------060405030505070503060705--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
