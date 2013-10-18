Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 802196B0112
	for <linux-mm@kvack.org>; Fri, 18 Oct 2013 00:17:07 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so3261443pbc.30
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 21:17:07 -0700 (PDT)
Message-ID: <1382069821.22110.168.camel@joe-AO722>
Subject: Re: [bug] get_maintainer.pl incomplete output
From: Joe Perches <joe@perches.com>
Date: Thu, 17 Oct 2013 21:17:01 -0700
In-Reply-To: <20131017121215.826ab6cced73118f3dba8d4f@linux-foundation.org>
References: <alpine.DEB.2.02.1310161738410.10147@chino.kir.corp.google.com>
	 <alpine.DEB.2.02.1310162046090.30995@chino.kir.corp.google.com>
	 <20131017121215.826ab6cced73118f3dba8d4f@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, Michal Hocko <mhocko@suse.cz>, "Kirill A.
 Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2013-10-17 at 12:12 -0700, Andrew Morton wrote:
> On Wed, 16 Oct 2013 20:51:18 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> 
> > I haven't looked closely at scripts/get_maintainer.pl, but I recently 
> > wrote a patch touching mm/vmpressure.c and it doesn't list the file's 
> > author, Anton Vorontsov <anton.vorontsov@linaro.org>.
> > 
> > Even when I do scripts/get_maintainer.pl -f mm/vmpressure.c, his entry is 
> > missing and git blame attributs >90% of the lines to his authorship.
> > 
> > $ ./scripts/get_maintainer.pl -f mm/vmpressure.c 
> > Tejun Heo <tj@kernel.org> (commit_signer:6/7=86%)
> > Michal Hocko <mhocko@suse.cz> (commit_signer:5/7=71%)
> > Andrew Morton <akpm@linux-foundation.org> (commit_signer:4/7=57%)
> > Li Zefan <lizefan@huawei.com> (commit_signer:3/7=43%)
> > "Kirill A. Shutemov" <kirill@shutemov.name> (commit_signer:1/7=14%)
> > linux-mm@kvack.org (open list:MEMORY MANAGEMENT)
> > linux-kernel@vger.kernel.org (open list)
> 
> get_maintainer should, by default, answer the question "who should I
> email about this file".  It clearly isn't doing this, and that's a
> pretty big fail.
> 
> I've learned not to trust it, so when I use it I always have to check
> its homework with "git log | grep Author" :(
> 
> Joe, pretty please?

Try this:

It adds authored/lines_added/lines_deleted to rolestats

For instance:

$ ./scripts/get_maintainer.pl -f mm/vmpressure.c
Tejun Heo <tj@kernel.org> (commit_signer:6/7=86%,authored:3/7=43%,removed_lines:15/21=71%)
Michal Hocko <mhocko@suse.cz> (commit_signer:5/7=71%,authored:3/7=43%,added_lines:22/408=5%,removed_lines:6/21=29%)
Andrew Morton <akpm@linux-foundation.org> (commit_signer:4/7=57%)
Li Zefan <lizefan@huawei.com> (commit_signer:3/7=43%)
"Kirill A. Shutemov" <kirill@shutemov.name> (commit_signer:1/7=14%)
Anton Vorontsov <anton.vorontsov@linaro.org> (authored:1/7=14%,added_lines:374/408=92%)
linux-mm@kvack.org (open list:MEMORY MANAGEMENT)
linux-kernel@vger.kernel.org (open list)

I haven't tested it much.

---

 scripts/get_maintainer.pl | 90 +++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 84 insertions(+), 6 deletions(-)

diff --git a/scripts/get_maintainer.pl b/scripts/get_maintainer.pl
index 5e4fb14..ee9adb8 100755
--- a/scripts/get_maintainer.pl
+++ b/scripts/get_maintainer.pl
@@ -98,6 +98,7 @@ my %VCS_cmds_git = (
     "available" => '(which("git") ne "") && (-d ".git")',
     "find_signers_cmd" =>
 	"git log --no-color --follow --since=\$email_git_since " .
+	    '--numstat --no-merges ' .
 	    '--format="GitCommit: %H%n' .
 		      'GitAuthor: %an <%ae>%n' .
 		      'GitDate: %aD%n' .
@@ -106,6 +107,7 @@ my %VCS_cmds_git = (
 	    " -- \$file",
     "find_commit_signers_cmd" =>
 	"git log --no-color " .
+	    '--numstat ' .
 	    '--format="GitCommit: %H%n' .
 		      'GitAuthor: %an <%ae>%n' .
 		      'GitDate: %aD%n' .
@@ -114,6 +116,7 @@ my %VCS_cmds_git = (
 	    " -1 \$commit",
     "find_commit_author_cmd" =>
 	"git log --no-color " .
+	    '--numstat ' .
 	    '--format="GitCommit: %H%n' .
 		      'GitAuthor: %an <%ae>%n' .
 		      'GitDate: %aD%n' .
@@ -125,6 +128,7 @@ my %VCS_cmds_git = (
     "blame_commit_pattern" => "^([0-9a-f]+) ",
     "author_pattern" => "^GitAuthor: (.*)",
     "subject_pattern" => "^GitSubject: (.*)",
+    "stat_pattern" => "(\\d+)\\t(\\d+)\\t\$file",
 );
 
 my %VCS_cmds_hg = (
@@ -152,6 +156,7 @@ my %VCS_cmds_hg = (
     "blame_commit_pattern" => "^([ 0-9a-f]+):",
     "author_pattern" => "^HgAuthor: (.*)",
     "subject_pattern" => "^HgSubject: (.*)",
+    "stat_pattern" => "(\\d+)\t(\\d+)\t\$file",
 );
 
 my $conf = which_conf(".get_maintainer.conf");
@@ -1269,20 +1274,30 @@ sub extract_formatted_signatures {
 }
 
 sub vcs_find_signers {
-    my ($cmd) = @_;
+    my ($cmd, $file) = @_;
     my $commits;
     my @lines = ();
     my @signatures = ();
+    my @authors = ();
+    my @stats = ();
 
     @lines = &{$VCS_cmds{"execute_cmd"}}($cmd);
 
     my $pattern = $VCS_cmds{"commit_pattern"};
+    my $author_pattern = $VCS_cmds{"author_pattern"};
+    my $stat_pattern = $VCS_cmds{"stat_pattern"};
+
+    $stat_pattern =~ s/(\$\w+)/$1/eeg;		#interpolate $stat_pattern
 
     $commits = grep(/$pattern/, @lines);	# of commits
 
+    @authors = grep(/$author_pattern/, @lines);
     @signatures = grep(/^[ \t]*${signature_pattern}.*\@.*$/, @lines);
+    @stats = grep(/$stat_pattern/, @lines);
+
+#    print("stats: <@stats>\n");
 
-    return (0, @signatures) if !@signatures;
+    return (0, @signatures, @authors) if !@signatures;
 
     save_commits_by_author(@lines) if ($interactive);
     save_commits_by_signer(@lines) if ($interactive);
@@ -1291,9 +1306,10 @@ sub vcs_find_signers {
 	@signatures = grep(!/${penguin_chiefs}/i, @signatures);
     }
 
+    my ($author_ref, $authors_ref) = extract_formatted_signatures(@authors);
     my ($types_ref, $signers_ref) = extract_formatted_signatures(@signatures);
 
-    return ($commits, @$signers_ref);
+    return ($commits, $signers_ref, $authors_ref, \@stats);
 }
 
 sub vcs_find_author {
@@ -1849,7 +1865,12 @@ sub vcs_assign {
 sub vcs_file_signoffs {
     my ($file) = @_;
 
+    my $authors_ref;
+    my $signers_ref;
+    my $stats_ref;
+    my @authors = ();
     my @signers = ();
+    my @stats = ();
     my $commits;
 
     $vcs_used = vcs_exists();
@@ -1858,13 +1879,58 @@ sub vcs_file_signoffs {
     my $cmd = $VCS_cmds{"find_signers_cmd"};
     $cmd =~ s/(\$\w+)/$1/eeg;		# interpolate $cmd
 
-    ($commits, @signers) = vcs_find_signers($cmd);
+    ($commits, $signers_ref, $authors_ref, $stats_ref) = vcs_find_signers($cmd, $file);
+    @signers = @{$signers_ref};
+    @authors = @{$authors_ref};
+    @stats = @{$stats_ref};
+
+#    print("commits: <$commits>\nsigners:<@signers>\nauthors: <@authors>\nstats: <@stats>\n");
 
     foreach my $signer (@signers) {
 	$signer = deduplicate_email($signer);
     }
 
     vcs_assign("commit_signer", $commits, @signers);
+    vcs_assign("authored", $commits, @authors);
+    if ($#authors == $#stats) {
+	my $stat_pattern = $VCS_cmds{"stat_pattern"};
+	$stat_pattern =~ s/(\$\w+)/$1/eeg;	#interpolate $stat_pattern
+
+	my $added = 0;
+	my $deleted = 0;
+	for (my $i = 0; $i <= $#stats; $i++) {
+	    if ($stats[$i] =~ /$stat_pattern/) {
+		$added += $1;
+		$deleted += $2;
+	    }
+	}
+	my @tmp_authors = uniq(@authors);
+	foreach my $author (@tmp_authors) {
+	    $author = deduplicate_email($author);
+	}
+	@tmp_authors = uniq(@tmp_authors);
+	my @list_added = ();
+	my @list_deleted = ();
+	foreach my $author (@tmp_authors) {
+	    my $auth_added = 0;
+	    my $auth_deleted = 0;
+	    for (my $i = 0; $i <= $#stats; $i++) {
+		if ($author eq deduplicate_email($authors[$i]) &&
+		    $stats[$i] =~ /$stat_pattern/) {
+		    $auth_added += $1;
+		    $auth_deleted += $2;
+		}
+	    }
+	    for (my $i = 0; $i < $auth_added; $i++) {
+		push(@list_added, $author);
+	    }
+	    for (my $i = 0; $i < $auth_deleted; $i++) {
+		push(@list_deleted, $author);
+	    }
+	}
+	vcs_assign("added_lines", $added, @list_added);
+	vcs_assign("removed_lines", $deleted, @list_deleted);
+    }
 }
 
 sub vcs_file_blame {
@@ -1887,6 +1953,10 @@ sub vcs_file_blame {
     if ($email_git_blame_signatures) {
 	if (vcs_is_hg()) {
 	    my $commit_count;
+	    my $commit_authors_ref;
+	    my $commit_signers_ref;
+	    my $stats_ref;
+	    my @commit_authors = ();
 	    my @commit_signers = ();
 	    my $commit = join(" -r ", @commits);
 	    my $cmd;
@@ -1894,19 +1964,27 @@ sub vcs_file_blame {
 	    $cmd = $VCS_cmds{"find_commit_signers_cmd"};
 	    $cmd =~ s/(\$\w+)/$1/eeg;	#substitute variables in $cmd
 
-	    ($commit_count, @commit_signers) = vcs_find_signers($cmd);
+	    ($commit_count, $commit_signers_ref, $commit_authors_ref, $stats_ref) = vcs_find_signers($cmd, $file);
+	    @commit_authors = @{$commit_authors_ref};
+	    @commit_signers = @{$commit_signers_ref};
 
 	    push(@signers, @commit_signers);
 	} else {
 	    foreach my $commit (@commits) {
 		my $commit_count;
+		my $commit_authors_ref;
+		my $commit_signers_ref;
+		my $stats_ref;
+		my @commit_authors = ();
 		my @commit_signers = ();
 		my $cmd;
 
 		$cmd = $VCS_cmds{"find_commit_signers_cmd"};
 		$cmd =~ s/(\$\w+)/$1/eeg;	#substitute variables in $cmd
 
-		($commit_count, @commit_signers) = vcs_find_signers($cmd);
+		($commit_count, $commit_signers_ref, $commit_authors_ref, $stats_ref) = vcs_find_signers($cmd, $file);
+		@commit_authors = @{$commit_authors_ref};
+		@commit_signers = @{$commit_signers_ref};
 
 		push(@signers, @commit_signers);
 	    }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
