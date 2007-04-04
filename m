Date: Wed, 4 Apr 2007 06:38:46 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: missing madvise functionality
Message-ID: <20070404133846.GL2986@holomorphy.com>
References: <46128051.9000609@redhat.com> <p73648dz5oa.fsf@bingen.suse.de> <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com> <20070403202937.GE355@devserv.devel.redhat.com> <20070404130918.GK2986@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070404130918.GK2986@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jakub Jelinek <jakub@redhat.com>
Cc: Ulrich Drepper <drepper@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 04, 2007 at 06:09:18AM -0700, William Lee Irwin III wrote:
> 	for (--i; i >= 0; --i) {
> 		if (pthread_join(th[i], NULL)) {
> 			perror("main: pthread_join failed");
> 			ret = EXIT_FAILURE;
> 		}
> 	}

Obligatory brown paper bag patch:


--- ./jakub.c.orig	2007-04-04 05:57:23.409493248 -0700
+++ ./jakub.c	2007-04-04 06:35:34.296043432 -0700
@@ -232,10 +232,14 @@ int main(int argc, char *argv[])
 		}
 	}
 	for (--i; i >= 0; --i) {
-		if (pthread_join(th[i], NULL)) {
+		void *status;
+
+		if (pthread_join(th[i], &status)) {
 			perror("main: pthread_join failed");
 			ret = EXIT_FAILURE;
 		}
+		if (status != (void *)tr_success)
+			ret = EXIT_FAILURE;
 	}
 	free(th);
 	getrusage(RUSAGE_SELF, &ru);


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
