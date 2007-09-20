Date: Thu, 20 Sep 2007 15:07:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 6/9] oom: add oom_kill_asking_task sysctl
In-Reply-To: <Pine.LNX.4.64.0709201502430.11226@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.9999.0709201505070.342@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319300.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319520.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201321070.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201321220.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201321380.25753@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709201502430.11226@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 20 Sep 2007, Christoph Lameter wrote:

> Acked-by: Christoph Lameter <clameter@sgi.com>
> 
> Maybe we need this also for unconstrained allocations?
> 

It already is, here's the relevant code (CONSTRAINT_NONE falls through to 
check sysctl_oom_kill_asking_task.  CONSTRAINT_MEMORY_POLICY will be 
modified in a separate patchset since it doesn't have anything to do with 
the serialization.

 [ Ok, well modifying CONSTRAINT_CPUSET didn't really have anything to do
   with serialization either, but it's included in this patchset so we can
   eliminate the need to take callback_mutex. ]


@@ -478,14 +479,16 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
 				"No available memory (MPOL_BIND)");
 		break;
 
-	case CONSTRAINT_CPUSET:
-		oom_kill_process(current, points,
-				"No available memory in cpuset");
-		break;
-
 	case CONSTRAINT_NONE:
 		if (sysctl_panic_on_oom)
 			panic("out of memory. panic_on_oom is selected\n");
+		/* Fall-through */
+	case CONSTRAINT_CPUSET:
+		if (sysctl_oom_kill_asking_task) {
+			oom_kill_process(current, points,
+					"Out of memory (oom_kill_asking_task)");
+			break;
+		}
 retry:
 		/*
 		 * Rambo mode: Shoot down a process and hope it solves whatever

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
