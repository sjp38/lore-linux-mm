Received: from toip4.srvr.bell.ca ([209.226.175.87])
          by tomts22-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20080123220609.RQGO18413.tomts22-srv.bellnexxia.net@toip4.srvr.bell.ca>
          for <linux-mm@kvack.org>; Wed, 23 Jan 2008 17:06:09 -0500
Date: Wed, 23 Jan 2008 17:06:08 -0500
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [RFC] Userspace tracing memory mappings
Message-ID: <20080123220608.GD2282@Krystal>
References: <20080123160454.GA15405@Krystal> <1201117112.8329.9.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <1201117112.8329.9.camel@nimitz.home.sr71.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: mbligh@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Dave Hansen (haveblue@us.ibm.com) wrote:
> On Wed, 2008-01-23 at 11:04 -0500, Mathieu Desnoyers wrote:
> > Since memory management is not my speciality, I would like to know if
> > there are some implementation details I should be aware of for my
> > LTTng userspace tracing buffers. Here is what I want to do :
> 
> Can you start with a little background by telling us what a userspace
> tracing buffer _is_?  Maybe a few requirements about what you need it to
> do and why, as well?
> 
> -- Dave
> 

Sure,

Userspace tracing is :

- A userspace process wants to record information to a circular ring
  buffer. This information has a timestamp. It should disrupt the
  timings minimally. The timestamps must be synchronized with the
  timestamps given to the kernel trace events so we can analyze all the
  information together.

- When one subbuffer of the ring buffer is filled, the information is
  ready to be read by a "trace dumping" process and sent to disk or to
  the network. At this point, the traced process raises a flag that will
  be checked periodically by the OS to wake up the disk/network dumper
  daemon. (for future reference, I use the term "buffer writer" when I
  talk about the traced process and the term "buffer reader" when
  talking about the disk/network dumper daemon).

There is more information in the email I sent to Frank Eigler. Please
feel free to ask for more if I am not clear about specific points.

A lot of the background information is already explained in the kernel
tracing paper I presented at OLS2006, it might be a good start :

http://ltt.polymtl.ca/papers/desnoyers-ols2006.pdf

Another requirement I am trying to meet is protection of tracing buffers
against corruption coming from other userspace process. K42 implemented
their tracing buffers shared system-wide : with the OS too. The
processes have full access to the kernel buffers and can therefore
corrupt the whole system's trace. This is something I would like not to
allow.

Mathieu

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
