Date: Fri, 6 Aug 2004 15:57:56 +0200
From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [proc.txt] Fix /proc/pid/statm documentation
Message-ID: <20040806135756.GA21411@k3.hellgate.ch>
References: <1091754711.1231.2388.camel@cube> <20040806094037.GB11358@k3.hellgate.ch> <20040806104630.GA17188@holomorphy.com> <20040806120123.GA23081@k3.hellgate.ch> <20040806121118.GE17188@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040806121118.GE17188@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Albert Cahalan <albert@users.sf.net>, linux-kernel mailing list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 06 Aug 2004 05:11:18 -0700, William Lee Irwin III wrote:
> Some of the 2.4 semantics just don't make sense. I would not find it
> difficult to explain what I believe correct semantics to be in a written
> document.

IMO this is a must for such files (and be it only some comments above
the code implementing them). I'm afraid that statm is carrying too much
historical baggage, though -- you would add yet another interpretation
of those 7 fields.

Tools reading statm would have to be updated anyway, so I'd rather
think about what could be done with a new (or just different) file.

For sysfs we have guidelines (e.g. sysfs.txt: "Attributes should be ASCII
text files, preferably with only one value per file. It is noted that it
may not be efficient to contain only value per file, so it is socially
acceptable to express an array of values of the same type.").

I'm not aware of anything comparable for proc, so it's hard to say
what a good solution would look like. Files like /proc/pid/status
are human-readable and maintenance-friendly (the parser can recognize
unknown values and gets a free label along with it; obsolete fields can
be removed). The downside is the performance aspect you pointed out:
Reading that file for every process just to grep for one or two values
is slow, and some of the unused data items might be expensive for the
kernel to produce in the first place.

It seems that most new information of interest is being added to
/proc/pid/status and friends these days. Are there any plans to
accomodate tool authors who are interested in additional information
but are wary of the increasing costs of these files?

A light-weight interface for tools could work like this (ugly):

$ cat /proc/pid.provided
Name SleepAVG Pid Tgid PPid VmSize VmLck VmData [...]
$ cat /proc/10235/VmSize.VmData
3380 144

Or use netlink maybe? It sure would be nice to monitor all processes
with lower overhead, and to have tools that can deal with new data
items without an update.

Roger
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
