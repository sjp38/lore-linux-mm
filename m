Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7590A6B0071
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 04:50:47 -0500 (EST)
From: Lubos Lunak <l.lunak@suse.cz>
Subject: Re: Improving OOM killer
Date: Thu, 11 Feb 2010 10:50:36 +0100
References: <201002012302.37380.l.lunak@suse.cz> <4B7320BF.2020800@redhat.com> <20100210221847.5d7bb3cb@lxorguk.ukuu.org.uk>
In-Reply-To: <20100210221847.5d7bb3cb@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Message-Id: <201002111050.36709.l.lunak@suse.cz>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Wednesday 10 of February 2010, Alan Cox wrote:
> > Killing the system daemon *is* a DoS.
> >
> > It would stop eg. the database or the web server, which is
> > generally the main task of systems that run a database or
> > a web server.
>
> One of the problems with picking on tasks that fork a lot is that
> describes apache perfectly. So a high loaded apache will get shot over a
> rapid memory eating cgi script.

 It will not. If it's only a single cgi script, that that child should be=20
selected by badness(), not the parent.

 I personally consider the logic of trying to find the offender using=20
badness() and then killing its child instead to be flawed. Already badness(=
)=20
itself should select what to kill and that should be killed. If it's a sing=
le=20
process that is the offender, it should be killed. If badness() decides it =
is=20
a whole subtree responsible for the situation, then the top of it needs to =
be=20
killed, otherwise the reason for the problem will remain.

 I expect the current logic of trying to kill children first is based on th=
e=20
system daemon logic, but if e.g. Apache master process itself causes OOM,=20
then the kernel itself has to way to find out if it's an important process=
=20
that should be protected or if it's some random process causing a forkbomb.=
=20
=46rom the kernel point's of view, if the Apache master process caused the=
=20
problem, the the problem should be solved there. If the reason for the=20
problem was actually e.g. a temporary high load on the server, then Apache =
is=20
probably misconfigured, and if it really should stay running no matter what=
,=20
then I guess that's the case to use oom_adj. But otherwise, from OOM killer=
's=20
point of view, that is where the problem was.

 Of course, the algorithm used in badness() should be careful not to propag=
ate=20
the excessive memory usage in that case to the innocent parent. This proble=
m=20
existed in the current code until it was fixed by the "/2" recently, and at=
=20
least my current proposal actually suffers from it too. But I envision=20
something like this could handle it nicely (pseudocode):

int oom_children_memory_usage(task)
    {
    // Memory shared with the parent should not be counted again.
    // Since it's expensive to find that out exactly, just assume
    // that the amount of shared memory that is not shared with the parent
    // is insignificant.
    total =3D unshared_rss(task)+unshared_swap(task);
    foreach_child(child,task)
        total +=3D oom_children_memory_usage(child);
    return total;
    }
int badness(task)
    {
    int total_memory =3D 0;
    ...
    int max_child_memory =3D 0; // memory used by that child
    int max_child_memory_2 =3D 0; // the 2nd most memory used by a child
    foreach_child(child,task)
        {
        if(sharing_the_same_memory(child,task))
            continue;
        if( real_time(child) > 1minute )
            continue; // running long, not a forkbomb
        int memory =3D oom_children_memory_usage(task);
        total_memory +=3D memory;
        if( memory > max_child_memory )
            {
            max_child_memory_2 =3D max_child_memory;
            max_child_memory =3D memory;
            }
        else if( memory > max_child_memory_2 )
            max_child_memory_2 =3D memory;
        }
    if( max_child_memory_2 !=3D 0 ) // there were at least two children
        {
        if( max_child_memory > max_child_memory_2 / 2 )
            {
// There is only a single child that contributes the majority of memory
// used by all children. Do not add it to the total, so that if that process
// is the biggest offender, the killer picks it instead of this parent.
            total_memory -=3D max_child_memory;
            }
        }
    ...
    }

 The logic is simply that a process is responsible for its children only if=
=20
their cost is similar. If one of them stands out, it is responsible for=20
itself and the parent is not. This is intentionally not done recursively in=
=20
oom_children_memory_usage() to cover also the case when e.g. parallel make=
=20
runs too many processes wrapped by shell, in that case making any of those=
=20
shell instances responsible for its child doesn't help anything, but making=
=20
make responsible for all of them helps.

 Alternatively, if somebody has a good use case where first going after a=20
child may make sense, then it perhaps would help to=20
add 'oom_recently_killed_children' to each task, and increasing it whenever=
 a=20
child is killed instead of the responsible parent. As soon as the value=20
within a reasonably short time is higher than let's say 5, then apparently=
=20
killing children does not help and the mastermind has to go.

=2D-=20
 Lubos Lunak
 openSUSE Boosters team, KDE developer
 l.lunak@suse.cz , l.lunak@kde.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
