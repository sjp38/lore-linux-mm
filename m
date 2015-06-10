Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 946766B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 01:52:33 -0400 (EDT)
Received: by igbzc4 with SMTP id zc4so27979091igb.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 22:52:33 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0014.hostedemail.com. [216.40.44.14])
        by mx.google.com with ESMTP id hu6si3069630igb.44.2015.06.09.22.52.32
        for <linux-mm@kvack.org>;
        Tue, 09 Jun 2015 22:52:32 -0700 (PDT)
Message-ID: <1433915549.2730.107.camel@perches.com>
Subject: [PATCH V2] checkpatch: Add some <foo>_destroy functions to
 NEEDLESS_IF tests
From: Joe Perches <joe@perches.com>
Date: Tue, 09 Jun 2015 22:52:29 -0700
In-Reply-To: <1433911166.2730.98.camel@perches.com>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
	 <20150609142523.b717dba6033ee08de997c8be@linux-foundation.org>
	 <1433894769.2730.87.camel@perches.com>
	 <1433911166.2730.98.camel@perches.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Julia Lawall <julia.lawall@lip6.fr>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

Sergey Senozhatsky has modified several destroy functions that can
now be called with NULL values.

 - kmem_cache_destroy()
 - mempool_destroy()
 - dma_pool_destroy()

Update checkpatch to warn when those functions are preceded by an if.

Update checkpatch to --fix all the calls too only when the code style
form is using leading tabs.

from:
	if (foo)
		<func>(foo);
to:
	<func>(foo);

Signed-off-by: Joe Perches <joe@perches.com>
---
V2: Remove useless debugging print messages and multiple quotemetas

 scripts/checkpatch.pl | 32 ++++++++++++++++++++++++++++----
 1 file changed, 28 insertions(+), 4 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 69c4716..87d3bf1aa 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -4800,10 +4800,34 @@ sub process {
 
 # check for needless "if (<foo>) fn(<foo>)" uses
 		if ($prevline =~ /\bif\s*\(\s*($Lval)\s*\)/) {
-			my $expr = '\s*\(\s*' . quotemeta($1) . '\s*\)\s*;';
-			if ($line =~ /\b(kfree|usb_free_urb|debugfs_remove(?:_recursive)?)$expr/) {
-				WARN('NEEDLESS_IF',
-				     "$1(NULL) is safe and this check is probably not required\n" . $hereprev);
+			my $tested = quotemeta($1);
+			my $expr = '\s*\(\s*' . $tested . '\s*\)\s*;';
+			if ($line =~ /\b(kfree|usb_free_urb|debugfs_remove(?:_recursive)?|(?:kmem_cache|mempool|dma_pool)_destroy)$expr/) {
+				my $func = $1;
+				if (WARN('NEEDLESS_IF',
+					 "$func(NULL) is safe and this check is probably not required\n" . $hereprev) &&
+				    $fix) {
+					my $do_fix = 1;
+					my $leading_tabs = "";
+					my $new_leading_tabs = "";
+					if ($lines[$linenr - 2] =~ /^\+(\t*)if\s*\(\s*$tested\s*\)\s*$/) {
+						$leading_tabs = $1;
+					} else {
+						$do_fix = 0;
+					}
+					if ($lines[$linenr - 1] =~ /^\+(\t+)$func\s*\(\s*$tested\s*\)\s*;\s*$/) {
+						$new_leading_tabs = $1;
+						if (length($leading_tabs) + 1 ne length($new_leading_tabs)) {
+							$do_fix = 0;
+						}
+					} else {
+						$do_fix = 0;
+					}
+					if ($do_fix) {
+						fix_delete_line($fixlinenr - 1, $prevrawline);
+						$fixed[$fixlinenr] =~ s/^\+$new_leading_tabs/\+$leading_tabs/;
+					}
+				}
 			}
 		}
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
