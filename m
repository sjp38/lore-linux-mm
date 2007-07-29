Date: Sun, 29 Jul 2007 05:53:52 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
Message-Id: <20070729055352.21797a85.pj@sgi.com>
In-Reply-To: <20070727232919.GA8960@one.firstfloor.org>
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	<20070727030040.0ea97ff7.akpm@linux-foundation.org>
	<1185531918.8799.17.camel@Homer.simpson.net>
	<200707271345.55187.dhazelton@enter.net>
	<46AA3680.4010508@gmail.com>
	<20070727231545.GA14457@atjola.homenet>
	<20070727232919.GA8960@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: B.Steinbrink@gmx.de, rene.herman@gmail.com, dhazelton@enter.net, efault@gmx.de, akpm@linux-foundation.org, mingo@elte.hu, frank@kingswood-consulting.co.uk, nickpiggin@yahoo.com.au, ray-lk@madrabbit.org, jesper.juhl@gmail.com, ck@vds.kolivas.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andi wrote:
> GNU sort uses a merge sort with temporary files on disk. Not sure
> how much it keeps in memory during that, but it's probably less
> than 150MB. 

If I'm reading the source code for GNU sort correctly, then the
following snippet of shell code displays how much memory it uses
for its primary buffer on typical GNU/Linux systems:

    head -2 /proc/meminfo | awk '
	NR == 1 { memtotal = $2 }
	NR == 2 { memfree = $2 }
	END     {
		   if (memfree > memtotal/8)
		       m = memfree
		   else
		       m = memtotal/8
		   print "sort size:", m/2, "kB"
	}
    '

That is, over simplifying, GNU sort looks at the first two entries
in /proc/meminfo, which for example on a machine near me happen to be:

  MemTotal:      2336472 kB
  MemFree:        110600 kB

and then uses one-half of whichever is -greater- of MemTotal/8 or
MemFree.

... However ... for the typical GNU locate updatedb run, it is sorting
the list of pathnames for almost all files on the system, which is
usually larger than fits in one of these sized buffers.   So it ends up
using quite a few of the temporary files you mention, which tends to
chew up easily freed memory.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
