Received: from issun5.hti.com ([130.210.202.3]) by issun6.hti.com
          (Netscape Messaging Server 3.6)  with ESMTP id AAA4BC5
          for <linux-mm@kvack.org>; Thu, 3 May 2001 12:24:05 -0500
Message-ID: <3AF19A9E.7090706@link.com>
Date: Thu, 03 May 2001 13:51:26 -0400
From: "Richard F Weber" <rfweber@link.com>
MIME-Version: 1.0
Subject: Re: About reading /proc/*/mem
References: <Pine.GSO.4.21.0105011231330.9771-100000@weyl.math.psu.edu> <3AEFF1D7.6090300@link.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard F Weber <rfweber@link.com>
Cc: Alexander Viro <viro@math.psu.edu>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Well, just wanted to send an e-mail to let the group know what I've 
found & what my current workaround is, as well as make sure that it's 
recorded somewhere that will get searchable to save future hackers the 
trouble.

So far the story is I'm trying to get access to another processes memory 
structure for non-intrusive debugging (mainly to just track statically 
allocated variables to see how they change).  The technique used on 
other Operating systems was to simply open /proc/pid/mem, lseek to the 
proper location, and read the value directly from the processes mapped 
memory.

Unfortunately, on Linux this is not the case.  It appears that 
/proc/pid/mem is not available to another process, unless there is a 
ptrace(PTRACE_ATTACH) to bind the two processes together.  However, the 
problem with this method is that ptrace forces the child process to do a 
SIGSTOP whenever any signal is received.  In a real-time system, this 
isn't a good method to debug a process when it's important for the 
process being debugged to run correctly.

This brings up an interesting feature though, if you access 
/proc/self/mem, you can access anywhere in that process.  A few people 
suggested using a debugging process, or debugging routines which would 
again be a bit intrusive for use.  However, if you make a child thread, 
the child thread will get executed independently, but still have full 
access to the native application's memory.  This will basically provide 
the functionality I'm looking for.

So in conclusion, I have a call to 
pthread_create(thread_ptr,NULL,debug_fn,NULL) which is used to create a 
new thread that is designed to run the debug_fn function, which is the 
main routine from the original debug application.

Thanks to everyone for answering my questions.  I think a few people 
suggested I look at threads, but I don't remember who you were.  Thanks 
again for your help.


BTW:  As a future feature suggestion, what about having a 
/proc/pid/nbmem that would provide non-blocking access to a processes 
memory.  I would think it'd be kind of a redundant hack in the kernel to 
allow this, and since it will be a security concern make it an option 
you have to turn on in the kernel for recompilation (of course if it was 
a module that'd be sweeter still).

--Rich


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
